# done

# frozen_string_literal: true

# active_supportの便利メソッドを使用している
require "active_support/core_ext/object/duplicable"

module ActiveModel
  # 属性値操作の汎用的な機能の追加
  class Attribute # :nodoc:

    # メソッドで孫クラスのインスタンスを返している
    class << self
      # ここの引数の「value」は属性値ではなくてメソッドから返却される値なので注意
      # from_database -> ActiveRecord(SQL)を基に生成されたオブジェクト？
      def from_database(name, value, type)
        FromDatabase.new(name, value, type)
      end

      # from_database -> ユーザーが作成したモデルを基に生成されたオブジェクト？
      def from_user(name, value, type, original_attribute = nil)
        FromUser.new(name, value, type, original_attribute)
      end

      # キャスト変換済という意味？
      def with_cast_value(name, value, type)
        WithCastValue.new(name, value, type)
      end

      def null(name)
        Null.new(name)
      end

      def uninitialized(name, type)
        Uninitialized.new(name, type)
      end
    end

    attr_reader :name, :value_before_type_cast, :type

    # このメソッドは直接呼び出さないでください。#from_databaseまたは#from_userを使用します
    def initialize(name, value_before_type_cast, type, original_attribute = nil)
      @name = name
      @value_before_type_cast = value_before_type_cast
      # Type::Value.new, Type::String.new, Type::Integer.newなどの
      # ~/activemodel/lib/active_model/type/***.rbのオブジェクトが引数になる
      # （というか普通にRubyの型オブジェクトを引数にとる。Railsのそれは各種モンキーパッチメソッドが付与されているだけ。たぶん）
      @type = type
      @original_attribute = original_attribute
    end

    def value
      # 偽の値を返す場合、 `defined？（「定義された？」）`は `|| =`よりも安価です。
      # type_cast -> 各孫クラスごとにそれぞれのvalue加工（型変換）の処理をする

      # Attribute.type_cast(value_before_type_cast) => TypeObject.cast_value(value_before_type_cast)
      # 各TypeのObjectのcastメソッドを、引数をvalue_before_type_castで起動して、Attributeの@valueを生成する
      @value = type_cast(value_before_type_cast) unless defined?(@value)
      @value
    end

    def original_value
      if assigned?
        original_attribute.original_value
      else
        type_cast(value_before_type_cast)
      end
    end

    def value_for_database
      type.serialize(value)
    end

    def changed?
      changed_from_assignment? || changed_in_place?
    end

    def changed_in_place?
      has_been_read? && type.changed_in_place?(original_value_for_database, value)
    end

    def forgetting_assignment
      with_value_from_database(value_for_database)
    end

    # 各種インスタンス生成（nullとuninitializedはまた別）
    def with_value_from_user(value)
      type.assert_valid_value(value)
      self.class.from_user(name, value, type, original_attribute || self)
    end

    def with_value_from_database(value)
      self.class.from_database(name, value, type)
    end

    def with_cast_value(value)
      self.class.with_cast_value(name, value, type)
    end

    def with_type(type)
      if changed_in_place?
        with_value_from_user(value).with_type(type)
      else
        self.class.new(name, value_before_type_cast, type, original_attribute)
      end
    end

    # Attributeクラスのメソッドが直接呼び出されたらエラーになる
    def type_cast(*)
      raise NotImplementedError
    end

    def initialized?
      true
    end

    def came_from_user?
      false
    end

    def has_been_read?
      defined?(@value)
    end

    def ==(other)
      self.class == other.class &&
        name == other.name &&
        value_before_type_cast == other.value_before_type_cast &&
        type == other.type
    end
    alias eql? ==

    def hash
      [self.class, name, value_before_type_cast, type].hash
    end

    def init_with(coder)
      @name = coder["name"]
      @value_before_type_cast = coder["value_before_type_cast"]
      @type = coder["type"]
      @original_attribute = coder["original_attribute"]
      @value = coder["value"] if coder.map.key?("value")
    end

    def encode_with(coder)
      coder["name"] = name
      coder["value_before_type_cast"] = value_before_type_cast unless value_before_type_cast.nil?
      coder["type"] = type if type
      coder["original_attribute"] = original_attribute if original_attribute
      coder["value"] = value if defined?(@value)
    end

    protected
      def original_value_for_database
        if assigned?
          original_attribute.original_value_for_database
        else
          _original_value_for_database
        end
      end

    private
      attr_reader :original_attribute
      alias :assigned? :original_attribute

      def initialize_dup(other)
        if defined?(@value) && @value.duplicable?
          @value = @value.dup
        end
      end

      def changed_from_assignment?
        assigned? && type.changed?(original_value, value, value_before_type_cast)
      end

      def _original_value_for_database
        type.serialize(original_value)
      end

      # ここから各種孫クラス
      # これらのcast変換の機能によって、「数字を扱う属性値（カラム）に文字列を入れたら数字になる」、みたいなRailsの処理を使うことができる！
      class FromDatabase < Attribute # :nodoc:
        # DB由来のオブジェクト（User.firstとかで最初に引っ張ってきたときの処理ぽい）ならdeserialize（オブジェクトの型に復元）する
        # （DBから引っ張ってきた値は初期状態ではシリアライズされているからそれを初期化時に戻す感じ。たぶん）
        # 「シリアライズ（serialize）とは、プログラミングでオプジェクト化されたデータを、
        # ファイルやストレージに保存したり、ネットワークで送受信したりできるような形に変換することを言います。」
        # http://cloudcafe.tech/?p=2639
        def type_cast(value)
          type.deserialize(value)
        end

        def _original_value_for_database
          value_before_type_cast
        end
      end

      class FromUser < Attribute # :nodoc:
        # user由来のオブジェクト（User.newとかでRailsの世界で作られた値の処理ぽい）ならcast（変換）メソッドのみを起動
        # cast例
        # https://qiita.com/natsuokawai/items/5ac1a9704805ff17b3f2
        #
        # [3] pry(main)> c.checked
        #  => false
        #[4] pry(main)> c.checked = 1
        #  => 1
        #[5] pry(main)> c.checked
        #  => true (数字がT/Fにキャストされている)
        #[6] pry(main)> c.checked = "off"
        #  => "off"
        #[7] pry(main)> c.checked
        #  => false (文字列が特殊な加工を経てT/Fにキャストされている)
        def type_cast(value)
          type.cast(value)
        end

        def came_from_user?
          !type.value_constructed_by_mass_assignment?(value_before_type_cast)
        end
      end

      # すでにキャスト済ならそのままvalueを返す
      class WithCastValue < Attribute # :nodoc:
        def type_cast(value)
          value
        end

        def changed_in_place?
          false
        end
      end

      class Null < Attribute # :nodoc:
        def initialize(name)
          super(name, nil, Type.default_value)
        end

        def type_cast(*)
          nil
        end

        def with_type(type)
          self.class.with_cast_value(name, nil, type)
        end

        def with_value_from_database(value)
          raise ActiveModel::MissingAttributeError, "can't write unknown attribute `#{name}`"
        end
        alias_method :with_value_from_user, :with_value_from_database
        alias_method :with_cast_value, :with_value_from_database
      end

      class Uninitialized < Attribute # :nodoc:
        UNINITIALIZED_ORIGINAL_VALUE = Object.new

        def initialize(name, type)
          super(name, nil, type)
        end

        def value
          if block_given?
            yield name
          end
        end

        def original_value
          UNINITIALIZED_ORIGINAL_VALUE
        end

        def value_for_database
        end

        def initialized?
          false
        end

        def forgetting_assignment
          dup
        end

        def with_type(type)
          self.class.new(name, type)
        end
      end

      # Ruby で内部クラスを private にする
      # Attribute class内部で定義された各種孫classをprivateに設定する
      # https://secret-garden.hatenablog.com/entry/2017/08/09/214431
      private_constant :FromDatabase, :FromUser, :Null, :Uninitialized, :WithCastValue
  end
end
