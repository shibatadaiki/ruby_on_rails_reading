# done

# frozen_string_literal: true

require "active_support/core_ext/array/extract_options"

module ActiveModel
  # == Active \Model \Validations
  #
  # Provides a full validation framework to your objects.
  #
  # A minimal implementation could be:
  #
  #   class Person
  #     include ActiveModel::Validations
  #
  #     attr_accessor :first_name, :last_name
  #
  #     validates_each :first_name, :last_name do |record, attr, value|
  #       record.errors.add attr, 'starts with z.' if value.to_s[0] == ?z
  #     end
  #   end
  #
  # Which provides you with the full standard validation stack that you
  # know from Active Record:
  #
  #   person = Person.new
  #   person.valid?                   # => true
  #   person.invalid?                 # => false
  #
  #   person.first_name = 'zoolander'
  #   person.valid?                   # => false
  #   person.invalid?                 # => true
  #   person.errors.messages          # => {first_name:["starts with z."]}
  #
  # Note that <tt>ActiveModel::Validations</tt> automatically adds an +errors+
  # method to your instances initialized with a new <tt>ActiveModel::Errors</tt>
  # object, so there is no need for you to do this manually.

  # ＃==アクティブな\ Model \ Validations
  #  ＃
  #  ＃オブジェクトに完全な検証フレームワークを提供します。
  #  ＃
  #  ＃最小限の実装は次のとおりです。
  #  ＃
  #  ＃クラスPerson
  #  ＃ActiveModel :: Validationsを含める
  #  ＃
  #  ＃attr_accessor：first_name、：last_name
  #  ＃
  #  ＃validates_each：first_name、：last_name do | record、attr、value |
  #  ＃record.errors.add attr、 'zで始まる' if value.to_s [0] ==？z
  #  ＃     終わり
  #  ＃   終わり
  #  ＃
  #  ＃完全な標準検証スタックを提供します
  #  ＃Active Recordから知る：
  #  ＃
  #  ＃person = Person.new
  #  ＃person.valid？ ＃=> true
  #  ＃person.invalid？ ＃=> false
  #  ＃
  #  ＃person.first_name = 'zoolander'
  #  ＃person.valid？ ＃=> false
  #  ＃person.invalid？ ＃=> true
  #  ＃person.errors.messages＃=> {first_name：["starts with z。"]}
  #  ＃
  #  ＃<tt> ActiveModel :: Validations </ tt>は+エラー+を自動的に追加することに注意してください
  #  ＃新しい<tt> ActiveModel :: Errors </ tt>で初期化されたインスタンスへのメソッド
  #  ＃オブジェクトなので、手動でこれを行う必要はありません。

  # rails validation => 各ClassMethodsで動的に error / false条件処理を定義して、callbacks処理に移譲する
  module Validations
    extend ActiveSupport::Concern

    included do
      extend ActiveModel::Naming
      extend ActiveModel::Callbacks
      extend ActiveModel::Translation

      extend  HelperMethods
      include HelperMethods

      attr_accessor :validation_context
      private :validation_context=
      define_callbacks :validate, scope: :name

      # この_validators attributesの中に、ハッシュ値としてのバリデーションオブジェクトが収集される
      # このオブジェクトが初期化されたときに、ClassMethodsで設定を読み込んで、動的にバリデーションを設定する（たぶん）
      # instance_writer: false => instance書き込み不可
      class_attribute :_validators, instance_writer: false, default: Hash.new { |h, k| h[k] = [] }
    end

    module ClassMethods
      # Validates each attribute against a block.
      #
      #   class Person
      #     include ActiveModel::Validations
      #
      #     attr_accessor :first_name, :last_name
      #
      #     validates_each :first_name, :last_name, allow_blank: true do |record, attr, value|
      #       record.errors.add attr, 'starts with z.' if value.to_s[0] == ?z
      #     end
      #   end
      #
      # Options:
      # * <tt>:on</tt> - Specifies the contexts where this validation is active.
      #   Runs in all validation contexts by default +nil+. You can pass a symbol
      #   or an array of symbols. (e.g. <tt>on: :create</tt> or
      #   <tt>on: :custom_validation_context</tt> or
      #   <tt>on: [:create, :custom_validation_context]</tt>)
      # * <tt>:allow_nil</tt> - Skip validation if attribute is +nil+.
      # * <tt>:allow_blank</tt> - Skip validation if attribute is blank.
      # * <tt>:if</tt> - Specifies a method, proc or string to call to determine
      #   if the validation should occur (e.g. <tt>if: :allow_validation</tt>,
      #   or <tt>if: Proc.new { |user| user.signup_step > 2 }</tt>). The method,
      #   proc or string should return or evaluate to a +true+ or +false+ value.
      # * <tt>:unless</tt> - Specifies a method, proc or string to call to
      #   determine if the validation should not occur (e.g. <tt>unless: :skip_validation</tt>,
      #   or <tt>unless: Proc.new { |user| user.signup_step <= 2 }</tt>). The
      #   method, proc or string should return or evaluate to a +true+ or +false+
      #   value.

      # ＃各属性をブロックに対して検証します。
      #      ＃
      #   class Person
      #     include ActiveModel::Validations
      #
      #     attr_accessor :first_name, :last_name
      #
      #     validates_each :first_name, :last_name, allow_blank: true do |record, attr, value|
      #       record.errors.add attr, 'starts with z.' if value.to_s[0] == ?z
      #     end
      #   end
      #      ＃
      #      ＃オプション：
      #      ＃* <tt>：on </ tt>-この検証がアクティブなコンテキストを指定します。
      #      ＃デフォルトではすべての検証コンテキストで実行されます+ nil +。シンボルを渡すことができます
      #      ＃またはシンボルの配列。 （例：<tt> on：：create </ tt>または
      #      ＃<tt> on：：custom_validation_context </ tt>または
      #      ＃<tt> on：[：create、：custom_validation_context] </ tt>）
      #      ＃* <tt>：allow_nil </ tt>-属性が+ nil +の場合、検証をスキップします。
      #      ＃* <tt>：allow_blank </ tt>-属性が空白の場合、検証をスキップします
      #      ＃* <tt>：if </ tt>-決定するために呼び出すメソッド、プロシージャ、または文字列を指定します
      #      ＃検証が必要な場合（例：<tt> if：：allow_validation </ tt>、
      #      ＃または<tt> if：Proc.new {| user | user.signup_step> 2} </ tt>）。メソッド、
      #      ＃procまたはstringは、+ true +または+ false +の値を返すか評価する必要があります。
      #      ＃* <tt>：unless </ tt>-呼び出すメソッド、プロシージャ、または文字列を指定します
      #      ＃検証を行わないかどうかを決定します（例：<tt> unless：：skip_validation </ tt>、
      #      ＃または<tt> unless：Proc.new {| user | user.signup_step <= 2} </ tt>）。の
      #      ＃メソッド、プロシージャ、または文字列は+ true +または+ false +を返すか評価する必要があります
      #      ＃値。

      # validates_with => active_model/validations/with.rb内のメソッド
      # _merge_attributes => active_model/validations/helper_methods.rb内のメソッド
      # BlockValidator => active_model/validator.rb内のクラス
      def validates_each(*attr_names, &block)
        # class Validatorを使用する（ BlockValidator < EachValidator < Validator ）
        validates_with BlockValidator, _merge_attributes(attr_names), &block
      end

      VALID_OPTIONS_FOR_VALIDATE = [:on, :if, :unless, :prepend].freeze # :nodoc:

      # Adds a validation method or block to the class. This is useful when
      # overriding the +validate+ instance method becomes too unwieldy and
      # you're looking for more descriptive declaration of your validations.
      #
      # This can be done with a symbol pointing to a method:
      #
      #   class Comment
      #     include ActiveModel::Validations
      #
      #     validate :must_be_friends
      #
      #     def must_be_friends
      #       errors.add(:base, 'Must be friends to leave a comment') unless commenter.friend_of?(commentee)
      #     end
      #   end
      #
      # With a block which is passed with the current record to be validated:
      #
      #   class Comment
      #     include ActiveModel::Validations
      #
      #     validate do |comment|
      #       comment.must_be_friends
      #     end
      #
      #     def must_be_friends
      #       errors.add(:base, 'Must be friends to leave a comment') unless commenter.friend_of?(commentee)
      #     end
      #   end
      #
      # Or with a block where self points to the current record to be validated:
      #
      #   class Comment
      #     include ActiveModel::Validations
      #
      #     validate do
      #       errors.add(:base, 'Must be friends to leave a comment') unless commenter.friend_of?(commentee)
      #     end
      #   end
      #
      # Note that the return value of validation methods is not relevant.
      # It's not possible to halt the validate callback chain.
      #
      # Options:
      # * <tt>:on</tt> - Specifies the contexts where this validation is active.
      #   Runs in all validation contexts by default +nil+. You can pass a symbol
      #   or an array of symbols. (e.g. <tt>on: :create</tt> or
      #   <tt>on: :custom_validation_context</tt> or
      #   <tt>on: [:create, :custom_validation_context]</tt>)
      # * <tt>:if</tt> - Specifies a method, proc or string to call to determine
      #   if the validation should occur (e.g. <tt>if: :allow_validation</tt>,
      #   or <tt>if: Proc.new { |user| user.signup_step > 2 }</tt>). The method,
      #   proc or string should return or evaluate to a +true+ or +false+ value.
      # * <tt>:unless</tt> - Specifies a method, proc or string to call to
      #   determine if the validation should not occur (e.g. <tt>unless: :skip_validation</tt>,
      #   or <tt>unless: Proc.new { |user| user.signup_step <= 2 }</tt>). The
      #   method, proc or string should return or evaluate to a +true+ or +false+
      #   value.
      #
      # NOTE: Calling +validate+ multiple times on the same method will overwrite previous definitions.

      # ＃クラスに検証メソッドまたはブロックを追加します。これは
      #      ＃+ validate +インスタンスメソッドをオーバーライドすると、扱いにくくなり、
      #      ＃検証のよりわかりやすい宣言を探しています。
      #      ＃
      #      ＃これは、メソッドを指すシンボルで実行できます。
      #      ＃
      #      ＃クラスコメント
      #      ＃ActiveModel :: Validationsを含める
      #      ＃
      #      ＃検証：must_be_friends
      #      ＃
      #      ＃def must_be_friends
      #      ＃errors.add（：base、 'コメントを残すには友達である必要があります'）commenter.friend_of？
      #      ＃     終わり
      #      ＃   終わり
      #      ＃
      #      ＃検証する現在のレコードとともに渡されるブロックを使用：
      #      ＃
      #      ＃クラスコメント
      #      ＃ActiveModel :: Validationsを含める
      #      ＃
      #      ＃検証する|コメント|
      #      ＃comment.must_be_friends
      #      ＃     終わり
      #      ＃
      #      ＃def must_be_friends
      #      ＃errors.add（：base、 'コメントを残すには友達である必要があります'）commenter.friend_of？
      #      ＃     終わり
      #      ＃   終わり
      #      ＃
      #      ＃または、検証対象の現在のレコードをselfが指すブロックを使用します。
      #      ＃
      #      ＃クラスコメント
      #      ＃ActiveModel :: Validationsを含める
      #      ＃
      #      ＃検証する
      #      ＃errors.add（：base、 'コメントを残すには友達である必要があります'）commenter.friend_of？
      #      ＃     終わり
      #      ＃   終わり
      #      ＃
      #      ＃検証メソッドの戻り値は関係がないことに注意してください。
      #      ＃検証コールバックチェーンを停止することはできません。
      #      ＃
      #      ＃オプション：
      #      ＃* <tt>：on </ tt>-この検証がアクティブなコンテキストを指定します。
      #      ＃デフォルトではすべての検証コンテキストで実行されます+ nil +。シンボルを渡すことができます
      #      ＃またはシンボルの配列。 （例：<tt> on：：create </ tt>または
      #      ＃<tt> on：：custom_validation_context </ tt>または
      #      ＃<tt> on：[：create、：custom_validation_context] </ tt>）
      #      ＃* <tt>：if </ tt>-決定するために呼び出すメソッド、プロシージャ、または文字列を指定します
      #      ＃検証が必要な場合（例：<tt> if：：allow_validation </ tt>、
      #      ＃または<tt> if：Proc.new {| user | user.signup_step> 2} </ tt>）。メソッド、
      #      ＃procまたはstringは、+ true +または+ false +の値を返すか評価する必要があります。
      #      ＃* <tt>：unless </ tt>-呼び出すメソッド、プロシージャ、または文字列を指定します
      #      ＃検証を行わないかどうかを決定します（例：<tt> unless：：skip_validation </ tt>、
      #      ＃または<tt> unless：Proc.new {| user | user.signup_step <= 2} </ tt>）。の
      #      ＃メソッド、プロシージャ、または文字列は+ true +または+ false +を返すか評価する必要があります
      #      ＃値。
      #      ＃
      #      ＃注：同じメソッドで+ validate +を複数回呼び出すと、以前の定義が上書きされます。
      def validate(*args, &block)
        # 配列の最後の要素がoption値の入ったハッシュであるというルールになっている？
        options = args.extract_options!

        if args.all? { |arg| arg.is_a?(Symbol) }
          options.each_key do |k|
            # VALID_OPTIONS_FOR_VALIDATE = [:on, :if, :unless, :prepend].freeze # :nodoc:
            # バリデーションメソッドのオプションが指定した値になっていなければエラー
            unless VALID_OPTIONS_FOR_VALIDATE.include?(k)
              raise ArgumentError.new("Unknown key: #{k.inspect}. Valid keys are: #{VALID_OPTIONS_FOR_VALIDATE.map(&:inspect).join(', ')}. Perhaps you meant to call `validates` instead of `validate`?")
            end
          end
        end

        #　'on'の設定が'if'のそれと一致していなければそのバリデーション条件設定を取り除く？
        if options.key?(:on)
          options = options.dup
          options[:on] = Array(options[:on])
          options[:if] = Array(options[:if])
          options[:if].unshift ->(o) {
            !(options[:on] & Array(o.validation_context)).empty?
          }
        end

        # バリデーションコールバックを動的に追加
        set_callback(:validate, *args, options, &block)
      end

      # List all validators that are being used to validate the model using
      # +validates_with+ method.
      #
      #   class Person
      #     include ActiveModel::Validations
      #
      #     validates_with MyValidator
      #     validates_with OtherValidator, on: :create
      #     validates_with StrictValidator, strict: true
      #   end
      #
      #   Person.validators
      #   # => [
      #   #      #<MyValidator:0x007fbff403e808 @options={}>,
      #   #      #<OtherValidator:0x007fbff403d930 @options={on: :create}>,
      #   #      #<StrictValidator:0x007fbff3204a30 @options={strict:true}>
      #   #    ]

      # ＃を使用してモデルを検証するために使用されているすべてのバリデーターをリストします
      #       ＃+ validates_with +メソッド。
      #       ＃
      #       ＃クラスPerson
      #       ＃ActiveModel :: Validationsを含める
      #       ＃
      #       ＃validates_with MyValidator
      #       ＃validates_with OtherValidator、on：：create
      #       ＃validates_with StrictValidator、strict：true
      #       ＃   終わり
      #       ＃
      #       ＃Person.validators
      #       ＃＃=> [
      #       ＃＃＃<MyValidator：0x007fbff403e808 @options = {}>、
      #       ＃＃＃<OtherValidator：0x007fbff403d930 @ options = {on：：create}>、
      #       ＃＃＃<StrictValidator：0x007fbff3204a30 @ options = {strict：true}>
      #       ＃＃]
      def validators
        _validators.values.flatten.uniq
      end

      # Clears all of the validators and validations.
      #
      # Note that this will clear anything that is being used to validate
      # the model for both the +validates_with+ and +validate+ methods.
      # It clears the validators that are created with an invocation of
      # +validates_with+ and the callbacks that are set by an invocation
      # of +validate+.
      #
      #   class Person
      #     include ActiveModel::Validations
      #
      #     validates_with MyValidator
      #     validates_with OtherValidator, on: :create
      #     validates_with StrictValidator, strict: true
      #     validate :cannot_be_robot
      #
      #     def cannot_be_robot
      #       errors.add(:base, 'A person cannot be a robot') if person_is_robot
      #     end
      #   end
      #
      #   Person.validators
      #   # => [
      #   #      #<MyValidator:0x007fbff403e808 @options={}>,
      #   #      #<OtherValidator:0x007fbff403d930 @options={on: :create}>,
      #   #      #<StrictValidator:0x007fbff3204a30 @options={strict:true}>
      #   #    ]
      #
      # If one runs <tt>Person.clear_validators!</tt> and then checks to see what
      # validators this class has, you would obtain:
      #
      #   Person.validators # => []
      #
      # Also, the callback set by <tt>validate :cannot_be_robot</tt> will be erased
      # so that:
      #
      #   Person._validate_callbacks.empty?  # => true
      #

      # ＃すべてのバリデーターと検証をクリアします。
      #      ＃
      #      ＃これにより、検証に使用されているものがすべてクリアされることに注意してください
      #      ＃+ validates_with +メソッドと+ validate +メソッドの両方のモデル。
      #      ＃次の呼び出しで作成されたバリデーターをクリアします
      #      ＃+ validates_with +と呼び出しによって設定されるコールバック
      #      + validate +の数。
      #      ＃
      #      ＃クラスPerson
      #      ＃ActiveModel :: Validationsを含める
      #      ＃
      #      ＃validates_with MyValidator
      #      ＃validates_with OtherValidator、on：：create
      #      ＃validates_with StrictValidator、strict：true
      #      ＃検証：cannot_be_robot
      #      ＃
      #      ＃def cannot_be_robot
      #      ＃errors.add（：base、 '人はロボットにはなれない'）if person_is_robot
      #      ＃     終わり
      #      ＃   終わり
      #      ＃
      #      ＃Person.validators
      #      ＃＃=> [
      #      ＃＃＃<MyValidator：0x007fbff403e808 @options = {}>、
      #      ＃＃＃<OtherValidator：0x007fbff403d930 @ options = {on：：create}>、
      #      ＃＃＃<StrictValidator：0x007fbff3204a30 @ options = {strict：true}>
      #      ＃＃]
      #      ＃
      #      ＃<tt> Person.clear_validators！</ tt>を実行してから、何を確認して
      #      ＃このクラスのバリデーターを使用すると、次のようになります。
      #      ＃
      #      ＃Person.validators＃=> []
      #      ＃
      #      ＃また、<tt> validate：cannot_be_robot </ tt>によって設定されたコールバックは消去されます
      #      ＃ そのため：
      #      ＃
      #      ＃Person._validate_callbacks.empty？ ＃=> true
      #      ＃
      def clear_validators!
        reset_callbacks(:validate)
        _validators.clear
      end

      # List all validators that are being used to validate a specific attribute.
      #
      #   class Person
      #     include ActiveModel::Validations
      #
      #     attr_accessor :name , :age
      #
      #     validates_presence_of :name
      #     validates_inclusion_of :age, in: 0..99
      #   end
      #
      #   Person.validators_on(:name)
      #   # => [
      #   #       #<ActiveModel::Validations::PresenceValidator:0x007fe604914e60 @attributes=[:name], @options={}>,
      #   #    ]

      # ＃特定の属性の検証に使用されているすべてのバリデーターをリストします。
      #       ＃
      #       ＃クラスPerson
      #       ＃ActiveModel :: Validationsを含める
      #       ＃
      #       ＃attr_accessor：name、：age
      #       ＃
      #       ＃validates_presence_of：name
      #       ＃validates_inclusion_of：age、in：0..99
      #       ＃   終わり
      #       ＃
      #       ＃Person.validators_on（：name）
      #       ＃＃=> [
      #       ＃＃＃<ActiveModel :: Validations :: PresenceValidator：0x007fe604914e60 @attributes = [：name]、@options = {}>、
      #       ＃＃]
      def validators_on(*attributes)
        attributes.flat_map do |attribute|
          _validators[attribute.to_sym]
        end
      end

      # Returns +true+ if +attribute+ is an attribute method, +false+ otherwise.
      #
      #  class Person
      #    include ActiveModel::Validations
      #
      #    attr_accessor :name
      #  end
      #
      #  User.attribute_method?(:name) # => true
      #  User.attribute_method?(:age)  # => false

      # ＃+ attributeが属性メソッドの場合は+ trueを返し、それ以外の場合は+ falseを返します。
      def attribute_method?(attribute)
        method_defined?(attribute)
      end

      # Copy validators on inheritance.
      # ＃継承時にバリデーターをコピーします。
      def inherited(base) #:nodoc:
        dup = _validators.dup
        base._validators = dup.each { |k, v| dup[k] = v.dup }
        super
      end
    end

    # Clean the +Errors+ object if instance is duped.
    # ＃インスタンスが複製された場合、+ Errors +オブジェクトを消去します。
    def initialize_dup(other) #:nodoc:
      @errors = nil
      super
    end

    # Returns the +Errors+ object that holds all information about attribute
    # error messages.
    #
    #   class Person
    #     include ActiveModel::Validations
    #
    #     attr_accessor :name
    #     validates_presence_of :name
    #   end
    #
    #   person = Person.new
    #   person.valid? # => false
    #   person.errors # => #<ActiveModel::Errors:0x007fe603816640 @messages={name:["can't be blank"]}>

    # ＃属性に関するすべての情報を保持する+ Errors +オブジェクトを返します
    #     ＃エラーメッセージ。
    def errors
      @errors ||= Errors.new(self)
    end

    # Runs all the specified validations and returns +true+ if no errors were
    # added otherwise +false+.
    #
    #   class Person
    #     include ActiveModel::Validations
    #
    #     attr_accessor :name
    #     validates_presence_of :name
    #   end
    #
    #   person = Person.new
    #   person.name = ''
    #   person.valid? # => false
    #   person.name = 'david'
    #   person.valid? # => true
    #
    # Context can optionally be supplied to define which callbacks to test
    # against (the context is defined on the validations using <tt>:on</tt>).
    #
    #   class Person
    #     include ActiveModel::Validations
    #
    #     attr_accessor :name
    #     validates_presence_of :name, on: :new
    #   end
    #
    #   person = Person.new
    #   person.valid?       # => true
    #   person.valid?(:new) # => false

    # ＃指定されたすべての検証を実行し、エラーがなかった場合は+ true +を返します
    #     ＃そうでなければ+ false +を追加。
    #     ＃
    #     ＃クラスPerson
    #     ＃ActiveModel :: Validationsを含める
    #     ＃
    #     ＃attr_accessor：name
    #     ＃validates_presence_of：name
    #     ＃   終わり
    #     ＃
    #     ＃person = Person.new
    #     ＃person.name = ''
    #     ＃person.valid？ ＃=> false
    #     ＃person.name = 'david'
    #     ＃person.valid？ ＃=> true
    #     ＃
    #     ＃オプションで、コンテキストを指定して、テストするコールバックを定義できます
    #     ＃に対して（コンテキストは<tt>：on </ tt>を使用した検証で定義されます）。
    #     ＃
    #     ＃クラスPerson
    #     ＃ActiveModel :: Validationsを含める
    #     ＃
    #     ＃attr_accessor：name
    #     ＃validates_presence_of：name、on：：new
    #     ＃   終わり
    #     ＃
    #     ＃person = Person.new
    #     ＃person.valid？ ＃=> true
    #     ＃person.valid？（：new）＃=> false


    # 検証処理の実体
    def valid?(context = nil)
      current_context, self.validation_context = validation_context, context
      errors.clear
      # 検証処理の実体
      run_validations!
    ensure
      self.validation_context = current_context
    end

    alias_method :validate, :valid?

    # Performs the opposite of <tt>valid?</tt>. Returns +true+ if errors were
    # added, +false+ otherwise.
    #
    #   class Person
    #     include ActiveModel::Validations
    #
    #     attr_accessor :name
    #     validates_presence_of :name
    #   end
    #
    #   person = Person.new
    #   person.name = ''
    #   person.invalid? # => true
    #   person.name = 'david'
    #   person.invalid? # => false
    #
    # Context can optionally be supplied to define which callbacks to test
    # against (the context is defined on the validations using <tt>:on</tt>).
    #
    #   class Person
    #     include ActiveModel::Validations
    #
    #     attr_accessor :name
    #     validates_presence_of :name, on: :new
    #   end
    #
    #   person = Person.new
    #   person.invalid?       # => false
    #   person.invalid?(:new) # => true
    #
    # validの逆
    def invalid?(context = nil)
      !valid?(context)
    end

    # Runs all the validations within the specified context. Returns +true+ if
    # no errors are found, raises +ValidationError+ otherwise.
    #
    # Validations with no <tt>:on</tt> option will run no matter the context. Validations with
    # some <tt>:on</tt> option will only run in the specified context.
    #
    # !をつけることでfalseをエラーに変換
    def validate!(context = nil)
      valid?(context) || raise_validation_error
    end

    # Hook method defining how an attribute value should be retrieved. By default
    # this is assumed to be an instance named after the attribute. Override this
    # method in subclasses should you need to retrieve the value for a given
    # attribute differently:
    #
    #   class MyClass
    #     include ActiveModel::Validations
    #
    #     def initialize(data = {})
    #       @data = data
    #     end
    #
    #     def read_attribute_for_validation(key)
    #       @data[key]
    #     end
    #   end
    #
    # ＃属性値を取得する方法を定義するフックメソッド。 デフォルトでは
    #     ＃これは、属性にちなんで名付けられたインスタンスであると見なされます。 これを上書き
    #     ＃特定の値を取得する必要がある場合のサブクラスのメソッド
    #     ＃別の属性：
    #
    # https://docs.ruby-lang.org/ja/latest/doc/spec=2fdef.html#alias
    # メソッドを動的に呼び出す
    alias :read_attribute_for_validation :send

  private
    def run_validations!
      _run_validate_callbacks
      errors.empty?
    end

    def raise_validation_error # :doc:
      raise(ValidationError.new(self))
    end
  end

  # = Active Model ValidationError
  #
  # Raised by <tt>validate!</tt> when the model is invalid. Use the
  # +model+ method to retrieve the record which did not validate.
  #
  #   begin
  #     complex_operation_that_internally_calls_validate!
  #   rescue ActiveModel::ValidationError => invalid
  #     puts invalid.model.errors
  #   end
  #
  # ＃=アクティブなモデルのValidationError
  #   ＃
  #   ＃モデルが無効な場合、<tt> validate！</ tt>によって発生します。 使用
  #   ＃+ model +メソッドを使用して、検証されなかったレコードを取得します。
  class ValidationError < StandardError
    attr_reader :model

    def initialize(model)
      @model = model
      errors = @model.errors.full_messages.join(", ")
      super(I18n.t(:"#{@model.class.i18n_scope}.errors.messages.model_invalid", errors: errors, default: :"errors.messages.model_invalid"))
    end
  end
end

# 各種バリデーション処理が書かれたvalidations/*.rbのファイルをimport
Dir[File.expand_path("validations/*.rb", __dir__)].each { |file| require file }
