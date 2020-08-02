# done

# frozen_string_literal: true

require "active_support/core_ext/module/anonymous"

module ActiveModel
  # == Active \Model \Validator
  #
  # ActiveModel::Validations::ClassMethods.validates_withと共に使用できる単純な基本クラス
  #
  #   class Person
  #     include ActiveModel::Validations
  #     validates_with MyValidator
  #   end
  #
  #   class MyValidator < ActiveModel::Validator
  #     def validate(record)
  #       if some_complex_logic
  #         record.errors.add(:base, "This record is invalid")
  #       end
  #     end
  #
  #     private
  #       def some_complex_logic
  #         # ...
  #       end
  #   end
  #
  #＃ActiveModel :: Validatorから継承するクラスは、メソッドを実装する必要があります
  #   ＃+ record +を受け入れる+ validate +と呼ばれます。
  #
  #   class Person
  #     include ActiveModel::Validations
  #     validates_with MyValidator
  #   end
  #
  #   class MyValidator < ActiveModel::Validator
  #     def validate(record)
  #       record # => 検証される個人インスタンス
  #       options # => validates_withに渡される非標準オプション
  #     end
  #   end
  #
  #＃検証エラーを発生させるには、+ record +のエラーに直接追加する必要があります
  #＃バリデーターメッセージ内から。  #
  #   class MyValidator < ActiveModel::Validator
  #     def validate(record)
  #       record.errors.add :base, "This is some custom error message"
  #       record.errors.add :first_name, "This is some complex validation"
  #       # etc...
  #     end
  #   end
  #
  # initializeメソッドに動作を追加するには、次のシグネチャを使用します。
  #
  #   class MyValidator < ActiveModel::Validator
  #     def initialize(options)
  #       super
  #       @my_custom_field = options[:field_name] || :first_name
  #     end
  #   end
  #
  # ＃バリデーターはアプリケーション全体で一度だけ初期化されることに注意してください
  #   ＃ライフサイクルであり、検証の実行ごとではありません。
  #   ＃
  #   ＃個々の属性を検証するためのカスタムバリデーターを追加する最も簡単な方法
  #   ＃は便利な<tt> ActiveModel :: EachValidator </ tt>を使用します。
  #
  #   class TitleValidator < ActiveModel::EachValidator
  #     def validate_each(record, attribute, value)
  #       record.errors.add attribute, 'must be Mr., Mrs., or Dr.' unless %w(Mr. Mrs. Dr.).include?(value)
  #     end
  #   end
  #
  # ＃これは+ validates +メソッドと組み合わせて使用できるようになりました
  #   ＃（これについて詳しくは、<tt> ActiveModel :: Validations :: ClassMethods.validates </ tt>を参照してください）。
  #
  #   class Person
  #     include ActiveModel::Validations
  #     attr_accessor :title
  #
  #     validates :title, presence: true, title: true
  #   end
  #
  # ＃そのような前提条件がある場合、そのバリデーターを使用しているクラスにアクセスすると便利な場合があります
  #   ＃存在する+ attr_accessor +として。 このクラスには、コンストラクタの<tt> options [：class] </ tt>を介してアクセスできます。
  #   ＃バリデーターを設定するには、コンストラクターをオーバーライドします。
  #
  #   class MyValidator < ActiveModel::Validator
  #     def initialize(options={})
  #       super
  #       options[:class].attr_accessor :custom_attribute
  #     end
  #   end
  class Validator
    attr_reader :options

    # バリデーションの種類を返却する

    # Returns the kind of the validator.
    #
    #   PresenceValidator.kind   # => :presence
    #   AcceptanceValidator.kind # => :acceptance
    def self.kind
      @kind ||= name.split("::").last.underscore.chomp("_validator").to_sym unless anonymous?
    end

    # + options +リーダーを通じて利用可能になるオプションを受け入れます。
    # optionの定義とバリデーション種類を返却する処理の定義
    def initialize(options = {})
      @options = options.except(:class).freeze
    end

    # Returns the kind for this validator.
    #
    #   PresenceValidator.new(attributes: [:username]).kind # => :presence
    #   AcceptanceValidator.new(attributes: [:terms]).kind  # => :acceptance
    def kind
      self.class.kind
    end

    # ＃サブクラスのこのメソッドを検証ロジックでオーバーライドし、エラーを追加します
    #     ＃必要に応じて、records + errors +配列に。
    #
    # 小クラス(EachValidator)に定義がないとエラー
    def validate(record)
      raise NotImplementedError, "Subclasses must implement a validate(record) method."
    end
  end

  # +EachValidator+ is a validator which iterates through the attributes given
  # in the options hash invoking the <tt>validate_each</tt> method passing in the
  # record, attribute and value.
  #
  # All \Active \Model validations are built on top of this validator.

  # ＃+ EachValidator +は、指定された属性を反復処理するバリデーターです
  #   ＃オプションハッシュの<tt> validate_each </ tt>メソッドを呼び出して、
  #   ＃レコード、属性、値。
  #   ＃
  #   ＃すべての\ Active \ Model検証は、このバリデーターの上に構築されます。
  # lib/active_model/validations/xxx.rbはEachValidatorを継承する？
  class EachValidator < Validator #:nodoc:
    attr_reader :attributes

    # Returns a new validator instance. All options will be available via the
    # +options+ reader, however the <tt>:attributes</tt> option will be removed
    # and instead be made available through the +attributes+ reader.

    # ＃新しいバリデーターインスタンスを返します。 すべてのオプションは、
    #     ＃+ options +リーダー、ただし<tt>：attributes </ tt>オプションは削除されます
    #     ＃代わりに、+ attributes +リーダーを介して使用できるようにします。
    #
    # attributesの定義とバリデーションの実行
    def initialize(options)
      @attributes = Array(options.delete(:attributes))
      raise ArgumentError, ":attributes cannot be blank" if @attributes.empty?
      super
      check_validity!
    end

    # Performs validation on the supplied record. By default this will call
    # +validate_each+ to determine validity therefore subclasses should
    # override +validate_each+ with validation logic.
    #
    # ＃指定されたレコードの検証を実行します。 デフォルトではこれは
    #     ＃+ validate_each +は有効性を決定するため、サブクラスは
    #     ＃+ validate_each +を検証ロジックでオーバーライドします。
    #
    # validate処理の本体
    def validate(record)
      attributes.each do |attribute|
        value = record.read_attribute_for_validation(attribute)
        # allow_blankオプションがあれば検証スルー
        next if (value.nil? && options[:allow_nil]) || (value.blank? && options[:allow_blank])
        # 小クラスに定義されたvalidate_each処理を実行する
        validate_each(record, attribute, value)
      end
    end

    #　＃サブクラスでこのメソッドを検証ロジックでオーバーライドし、追加
    #     ＃必要に応じて、records + errors +配列へのエラー。
    def validate_each(record, attribute, value)
      raise NotImplementedError, "Subclasses must implement a validate_each(record, attribute, value) method"
    end

    #　＃検証を許可するイニシャライザによって呼び出されるフックメソッド
    #     ＃指定された引数が有効であること。 たとえば、
    #     ＃+ ArgumentError +無効なオプションが指定された場合。
    def check_validity!
      #　＃サブクラスでこのメソッドを検証ロジックでオーバーライドし、追加
    end
  end

  # ＃+ BlockValidator +は、初期化時にブロックを受け取る特別な+ EachValidator +です。
  #   ＃検証される属性ごとにこのブロックを呼び出します。 + validates_each +はこのバリデーターを使用します。
  #
  # blockの定義と、バリデーション処理の定義
  #
  # BlockValidator => validate: に付与されたブロックパラメータのバリデーション処理付与
  class BlockValidator < EachValidator #:nodoc:
    def initialize(options, &block)
      @block = block
      super
    end

    private
      def validate_each(record, attribute, value)
        @block.call(record, attribute, value)
      end
  end
end
