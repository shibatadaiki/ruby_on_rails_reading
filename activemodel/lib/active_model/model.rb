# done

# frozen_string_literal: true

module ActiveModel
  # == Active \Model \Basic \Model
  #
  # Includes the required interface for an object to interact with
  # Action Pack and Action View, using different Active Model modules.
  # It includes model name introspections, conversions, translations and
  # validations. Besides that, it allows you to initialize the object with a
  # hash of attributes, pretty much like Active Record does.
  #
  # A minimal implementation could be:
  #
  #   class Person
  #     include ActiveModel::Model
  #     attr_accessor :name, :age
  #   end
  #
  #   person = Person.new(name: 'bob', age: '18')
  #   person.name # => "bob"
  #   person.age  # => "18"
  #
  # Note that, by default, <tt>ActiveModel::Model</tt> implements <tt>persisted?</tt>
  # to return +false+, which is the most common case. You may want to override
  # it in your class to simulate a different scenario:
  #
  #   class Person
  #     include ActiveModel::Model
  #     attr_accessor :id, :name
  #
  #     def persisted?
  #       self.id == 1
  #     end
  #   end
  #
  #   person = Person.new(id: 1, name: 'bob')
  #   person.persisted? # => true
  #
  # Also, if for some reason you need to run code on <tt>initialize</tt>, make
  # sure you call +super+ if you want the attributes hash initialization to
  # happen.
  #
  #   class Person
  #     include ActiveModel::Model
  #     attr_accessor :id, :name, :omg
  #
  #     def initialize(attributes={})
  #       super
  #       @omg ||= true
  #     end
  #   end
  #
  #   person = Person.new(id: 1, name: 'bob')
  #   person.omg # => true
  #
  # For more detailed information on other functionalities available, please
  # refer to the specific modules included in <tt>ActiveModel::Model</tt>
  # (see below).

  # ＃==アクティブな\ Model \ Basic \ Model
  #  ＃
  #  ＃オブジェクトが対話するために必要なインターフェースを含みます
  #  ＃異なるアクティブモデルモジュールを使用したアクションパックとアクションビュー。
  #  ＃モデル名のイントロスペクション、変換、翻訳、および
  #  ＃検証。その上、それはあなたがオブジェクトを初期化することを可能にします
  #  ＃Active Recordとほとんど同じように、属性のハッシュ。
  #  ＃
  #  ＃最小限の実装は次のとおりです。
  #  ＃
  #  ＃クラスPerson
  #  ＃ActiveModel :: Modelを含める
  #  ＃attr_accessor：name、：age
  #  ＃   終わり
  #  ＃
  #  ＃person = Person.new（name： 'bob'、age： '18'）
  #  ＃person.name＃=> "bob"
  #  ＃person.age＃=> "18"
  #  ＃
  #  ＃デフォルトでは、<tt> ActiveModel :: Model </ tt>は<tt> persisted？</ tt>を実装することに注意してください
  #  ＃最も一般的なケースである+ false +を返します。オーバーライドしたいかもしれません
  #  ＃クラスでそれを使用して、異なるシナリオをシミュレートします。
  #  ＃
  #  ＃クラスPerson
  #  ＃ActiveModel :: Modelを含める
  #  ＃attr_accessor：id、：name
  #  ＃
  #  ＃defは持続しましたか？
  #  ＃self.id == 1
  #  ＃     終わり
  #  ＃   終わり
  #  ＃
  #  ＃person = Person.new（id：1、name： 'bob'）
  #  ＃person.persisted？ ＃=> true
  #  ＃
  #  ＃また、何らかの理由で<tt> initialize </ tt>でコードを実行する必要がある場合は、
  #  ＃属性ハッシュを初期化したい場合は、必ず+ super +を呼び出します
  #  ＃起こります。
  #  ＃
  #  ＃クラスPerson
  #  ＃ActiveModel :: Modelを含める
  #  ＃attr_accessor：id、：name、：omg
  #  ＃
  #  ＃def initialize（attributes = {}）
  #  ＃       素晴らしい
  #  ＃@omg || = true
  #  ＃     終わり
  #  ＃   終わり
  #  ＃
  #  ＃person = Person.new（id：1、name： 'bob'）
  #  ＃person.omg＃=> true
  #  ＃
  #  ＃利用可能な他の機能の詳細については、
  #  ＃<tt> ActiveModel :: Model </ tt>に含まれる特定のモジュールを参照
  #  ＃ （下記参照）。

  # エンドユーザーが手動で実行したいような機能はここにあるので全てということ。。？
  module Model
    extend ActiveSupport::Concern
    include ActiveModel::AttributeAssignment
    include ActiveModel::Validations
    include ActiveModel::Conversion

    included do
      extend ActiveModel::Naming
      extend ActiveModel::Translation
    end

    # Initializes a new model with the given +params+.
    #
    #   class Person
    #     include ActiveModel::Model
    #     attr_accessor :name, :age
    #   end
    #
    #   person = Person.new(name: 'bob', age: '18')
    #   person.name # => "bob"
    #   person.age  # => "18"
    def initialize(attributes = {})
      assign_attributes(attributes) if attributes

      super()
    end

    # Indicates if the model is persisted. Default is +false+.
    #
    #  class Person
    #    include ActiveModel::Model
    #    attr_accessor :id, :name
    #  end
    #
    #  person = Person.new(id: 1, name: 'bob')
    #  person.persisted? # => false
    def persisted?
      false
    end
  end
end
