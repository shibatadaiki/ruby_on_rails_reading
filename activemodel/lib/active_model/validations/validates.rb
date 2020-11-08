# done

# frozen_string_literal: true

require "active_support/core_ext/hash/slice"

module ActiveModel
  module Validations
    module ClassMethods
      # ＃このメソッドは、すべてのデフォルトのバリデーターとカスタム
      #       ＃「バリデーター」で終わるバリデータークラス。 Railsのデフォルト
      #       ＃バリデーターを作成することにより、特定のクラス内でオーバーライドできます
      #       ＃PresenceValidatorなど、代わりにカスタムバリデータークラス。
      #       ＃
      #       ＃デフォルトのレールバリデーターの使用例：
      #
      #   validates :username, absence: true
      #   validates :terms, acceptance: true
      #   validates :password, confirmation: true
      #   validates :username, exclusion: { in: %w(admin superuser) }
      #   validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, on: :create }
      #   validates :age, inclusion: { in: 0..9 }
      #   validates :first_name, length: { maximum: 30 }
      #   validates :age, numericality: true
      #   validates :username, presence: true
      #
      # ＃+ validates +メソッドの威力は、カスタムバリデーターを使用するとき
      #       ＃指定された属性の1回の呼び出しでのデフォルトのバリデーター。
      #
      #   class EmailValidator < ActiveModel::EachValidator
      #     def validate_each(record, attribute, value)
      #       record.errors.add attribute, (options[:message] || "is not an email") unless
      #         /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i.match?(value)
      #     end
      #   end
      #
      #   class Person
      #     include ActiveModel::Validations
      #     attr_accessor :name, :email
      #
      #     validates :name, presence: true, length: { maximum: 100 }
      #     validates :email, presence: true, email: true
      #   end
      #
      # ＃バリデータークラスは、検証されるクラス内にも存在する可能性があります
      #       ＃バリデーターのカスタムモジュールを必要に応じて含めることができます。
      #
      #   class Film
      #     include ActiveModel::Validations
      #
      #     class TitleValidator < ActiveModel::EachValidator
      #       def validate_each(record, attribute, value)
      #         record.errors.add attribute, "must start with 'the'" unless /\Athe/i.match?(value)
      #       end
      #     end
      #
      #     validates :name, title: true
      #   end
      #
      # ＃さらに、バリデータークラスは別の名前空間にありますが、
      #       ＃任意のクラス内で使用されます。
      #
      #   validates :name, :'film/title' => true
      #
      # ＃バリデーターハッシュは正規表現、範囲、配列も処理できます
      #       ＃およびショートカット形式の文字列。
      #
      #   validates :email, format: /@/
      #   validates :role, inclusion: %w(admin contributor)
      #   validates :password, length: 6..20
      #
      # ＃ショートカットフォームを使用すると、範囲と配列が
      #      ＃バリデーターの初期化子を<tt> options [：in] </ tt>として、他の型
      #      ＃正規表現と文字列を含めて、<tt> options [：with] </ tt>として渡されます。
      #      ＃
      #      ＃バリデータと共に使用できるオプションのリストもあります：
      #      ＃
      #      ＃* <tt>：on </ tt>-この検証がアクティブなコンテキストを指定します。
      #      ＃デフォルトではすべての検証コンテキストで実行されます+ nil +。シンボルを渡すことができます
      #      ＃またはシンボルの配列。 （例：<tt> on：：create </ tt>または
      #      ＃<tt> on：：custom_validation_context </ tt>または
      #      ＃<tt> on：[：create、：custom_validation_context] </ tt>）
      #      ＃* <tt>：if </ tt>-決定するために呼び出すメソッド、プロシージャ、または文字列を指定します
      #      ＃検証が必要な場合（例：<tt> if：：allow_validation </ tt>、
      #      ＃または<tt> if：Proc.new {| user | user.signup_step> 2} </ tt>）。メソッド、
      #      ＃procまたはstringは、+ true +または+ false +の値を返すか評価する必要があります。
      #      ＃* <tt>：unless </ tt>-決定するために呼び出すメソッド、プロシージャ、または文字列を指定します
      #      ＃検証を行わない場合（例：<tt> unless：：skip_validation </ tt>、
      #      ＃または<tt> unless：Proc.new {| user | user.signup_step <= 2} </ tt>）。の
      #      ＃メソッド、プロシージャ、または文字列は、+ true +を返すか、評価する必要があります。
      #      ＃+ false +値。
      #      ＃* <tt>：allow_nil </ tt>-属性が+ nil +の場合、検証をスキップします。
      #      ＃* <tt>：allow_blank </ tt>-属性が空白の場合、検証をスキップします
      #      ＃* <tt>：strict </ tt>-<tt>：strict </ tt>オプションがtrueに設定されている場合
      #      ＃エラーを追加する代わりにActiveModel :: StrictValidationFailedを発生させます。
      #      ＃<tt>：strict </ tt>オプションは、その他の例外にも設定できます。
      #
      # Example:
      #
      #   validates :password, presence: true, confirmation: true, if: :password_required?
      #   validates :token, length: 24, strict: TokenLengthException
      #
      # ＃最後に、オプション+：if +、+：unless +、+：on +、+：allow_blank +、+：allow_nil +、+：strict +
      #       ＃と+：message +は、特定のバリデーターにハッシュとして与えることができます：
      #
      #   validates :password, presence: { if: :password_required?, message: 'is forgotten.' }, confirmation: true
      def validates(*attributes)
        # optionsのみを抽出してdup
        defaults = attributes.extract_options!.dup
        # default_keyの中に含まれているバリデーションをsliceして取り出す
        validations = defaults.slice!(*_validates_default_keys)

        # 少なくとも1つのattribute, validationを指定する必要があります
        raise ArgumentError, "You need to supply at least one attribute" if attributes.empty?
        raise ArgumentError, "You need to supply at least one validation" if validations.empty?

        # default(options)にattributesをセット
        defaults[:attributes] = attributes

        validations.each do |key, options|
          key = "#{key.to_s.camelize}Validator"

          # カスタムバリデーターなどの時の検証用に？バリデータークラスが正常に定義されているかを確認
          begin
            # constantize -> Railsのクラスにアクセス
            # const_get => name で指定される名前の定数の値を取り出します。
            #              Module#const_defined? と違って Object を特別扱いすることはありません。
            validator = key.include?("::") ? key.constantize : const_get(key)
          rescue NameError
            raise ArgumentError, "Unknown validator: '#{key}'"
          end

          # そのクラスに特にバリデーションが指定されていなかったらスルー
          next unless options

          # active_model/validations/xxx.rbにある各種バリデーションファイルと、カスタムバリデーターファイルの
          # バリデーション処理を validates_with でセッティングする。
          validates_with(validator, defaults.merge(_parse_validates_options(options)))
        end
      end

      # ＃このメソッドは、最後まで修正できない検証を定義するために使用されます
      #       ＃人のユーザーがあり、例外的と見なされています。 つまり、bangで定義された各バリデーター
      #       ＃または<tt>：strict </ tt>オプションを<tt> true </ tt>に設定すると、常に発生します
      #       ＃エラーを追加する代わりに<tt> ActiveModel :: StrictValidationFailed </ tt>
      #       ＃検証が失敗した場合。 詳細については、<tt>検証</ tt>を参照してください
      #       ＃検証自体。
      #
      #   class Person
      #     include ActiveModel::Validations
      #
      #     attr_accessor :name
      #     validates! :name, presence: true
      #   end
      #
      #   person = Person.new
      #   person.name = ''
      #   person.valid?
      #   # => ActiveModel::StrictValidationFailed: Name can't be blank
      #
      # validates! -> 強制的に例外を出すバリデーションを設定
      def validates!(*attributes)
        options = attributes.extract_options!
        options[:strict] = true
        validates(*(attributes << options))
      end

      # ActiveModel::EachValidatorなどのカスタムバリデーターをActiveModel::EachValidatorを継承することで作成できる
      # （わかりづらそう）
    private
      # ＃カスタムバリデーターを作成するとき、指定できると便利かもしれません
      #       ＃追加のデフォルトキー。 これは、このメソッドを上書きすることで実行できます。
      #
      # default_keyをハッシュのkeyにしてバリデーションに追加するメソッドを指定する
      def _validates_default_keys
        [:if, :unless, :on, :allow_blank, :allow_nil, :strict]
      end

      # 送られてきた生のoption値を、Validationsで使うoptions形式（Hash形式）にparseする
      def _parse_validates_options(options)
        case options
        when TrueClass
          {}
        when Hash
          options
        when Range, Array
          { in: options }
        else
          { with: options }
        end
      end
    end
  end
end
