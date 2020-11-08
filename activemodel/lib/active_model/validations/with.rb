# done

# frozen_string_literal: true

require "active_support/core_ext/array/extract_options"

module ActiveModel
  module Validations
    # activemodel/lib/active_model/validator.rbのclass EachValidator < Validatorを継承
    class WithValidator < EachValidator # :nodoc:
      def validate_each(record, attr, val)
        method_name = options[:with]

        # https://docs.ruby-lang.org/ja/latest/method/Method/i/arity.html
        # arity -> Integer[permalink][rdoc]
        #メソッドが受け付ける引数の数を返します。
        #ただし、メソッドが可変長引数を受け付ける場合、負の整数
        if record.method(method_name).arity == 0
          record.send method_name
        else
          record.send method_name, attr
        end
      end
    end

    # validations module（を付与しているClass）にクラスメソッドを追加する
    module ClassMethods
      #＃レコードを指定された1つまたは複数のクラスに渡し、それらを許可します
      #＃より複雑な条件に基づいてエラーを追加します。      #
      #
      #   class Person
      #     include ActiveModel::Validations
      #     validates_with MyValidator
      #   end
      #
      #   class MyValidator < ActiveModel::Validator
      #     def validate(record)
      #       if some_complex_logic
      #         record.errors.add :base, 'This record is invalid'
      #       end
      #     end
      #
      #     private
      #       def some_complex_logic
      #         # ...
      #       end
      #   end
      #
      # You may also pass it multiple classes, like so:
      # 次のように、複数のクラスを渡すこともできます。
      #
      #   class Person
      #     include ActiveModel::Validations
      #     validates_with MyValidator, MyOtherValidator, on: :create
      #   end
      #
      # Configuration options:
      # * <tt>:on</tt> - Specifies the contexts where this validation is active.
      #   Runs in all validation contexts by default +nil+. You can pass a symbol
      #   or an array of symbols. (e.g. <tt>on: :create</tt> or
      #   <tt>on: :custom_validation_context</tt> or
      #   <tt>on: [:create, :custom_validation_context]</tt>)
      # * <tt>:if</tt> - Specifies a method, proc or string to call to determine
      #   if the validation should occur (e.g. <tt>if: :allow_validation</tt>,
      #   or <tt>if: Proc.new { |user| user.signup_step > 2 }</tt>).
      #   The method, proc or string should return or evaluate to a +true+ or
      #   +false+ value.
      # * <tt>:unless</tt> - Specifies a method, proc or string to call to
      #   determine if the validation should not occur
      #   (e.g. <tt>unless: :skip_validation</tt>, or
      #   <tt>unless: Proc.new { |user| user.signup_step <= 2 }</tt>).
      #   The method, proc or string should return or evaluate to a +true+ or
      #   +false+ value.
      # * <tt>:strict</tt> - Specifies whether validation should be strict.
      #   See <tt>ActiveModel::Validations#validates!</tt> for more information.
      #
      # If you pass any additional configuration options, they will be passed
      # to the class and available as +options+:
      #
      # ＃設定オプション：
      #      ＃* <tt>：on </ tt>-この検証がアクティブなコンテキストを指定します。
      #      ＃デフォルトではすべての検証コンテキストで実行されます+ nil +。シンボルを渡すことができます
      #      ＃またはシンボルの配列。 （例：<tt> on：：create </ tt>または
      #      ＃<tt> on：：custom_validation_context </ tt>または
      #      ＃<tt> on：[：create、：custom_validation_context] </ tt>）
      #      ＃* <tt>：if </ tt>-決定するために呼び出すメソッド、プロシージャ、または文字列を指定します
      #      ＃検証が必要な場合（例：<tt> if：：allow_validation </ tt>、
      #      ＃または<tt> if：Proc.new {| user | user.signup_step> 2} </ tt>）。
      #      ＃メソッド、プロシージャ、または文字列は、+ true +または
      #      ＃+ false +値。
      #      ＃* <tt>：unless </ tt>-呼び出すメソッド、プロシージャ、または文字列を指定します
      #      ＃検証を行わないかどうかを決定
      #      ＃（例：<tt> unless：：skip_validation </ tt>、または
      #      ＃<tt>以下を除く：Proc.new {| user | user.signup_step <= 2} </ tt>）。
      #      ＃メソッド、プロシージャ、または文字列は、+ true +または
      #      ＃+ false +値。
      #      ＃* <tt>：strict </ tt>-検証を厳密にする必要があるかどうかを指定します。
      #      ＃詳細は、<tt> ActiveModel :: Validations＃validates！</ tt>を参照してください。
      #      ＃
      #      ＃追加の構成オプションを渡すと、それらが渡されます
      #      ＃クラスに+ options +として利用可能：
      #
      #   class Person
      #     include ActiveModel::Validations
      #     validates_with MyValidator, my_custom_key: 'my custom value'
      #   end
      #
      #   class MyValidator < ActiveModel::Validator
      #     def validate(record)
      #       options[:my_custom_key] # => "my custom value"
      #     end
      #   end
      #
      # lib/active_model/validations/xxx.rbのクラスオブジェクトと、対象属性値を都度検証している！
      def validates_with(*args, &block)
        options = args.extract_options!
        options[:class] = self

        # BlockValidatorオブジェクトとoptionsハッシュを同一にeachで回して
        # _validators[attribute.to_sym] << validatorオブジェクトとして整理している？
        args.each do |klass|
          validator = klass.new(options, &block)

          if validator.respond_to?(:attributes) && !validator.attributes.empty?
            # 属性値があれば属性値のキーにバリデーションオブジェクトを追加
            validator.attributes.each do |attribute|
              _validators[attribute.to_sym] << validator
            end
          else
            # なければ削除？
            _validators[nil] << validator
          end

          validate(validator, options)
        end
      end
    end

    #＃レコードを指定された1つまたは複数のクラスに渡し、それらを許可します
    #＃より複雑な条件に基づいてエラーを追加します。    #
    #
    #   class Person
    #     include ActiveModel::Validations
    #
    #     validate :instance_validations
    #
    #     def instance_validations
    #       validates_with MyValidator
    #     end
    #   end
    #
    #＃詳細については、クラスメソッドのドキュメントを参照してください
    #＃独自のバリデーターを作成します。
    #＃
    #＃次のように、複数のクラスを渡すこともできます。
    #
    #   class Person
    #     include ActiveModel::Validations
    #
    #     validate :instance_validations, on: :create
    #
    #     def instance_validations
    #       validates_with MyValidator, MyOtherValidator
    #     end
    #   end
    #
    #＃標準構成オプション（<tt>：on </ tt>、<tt>：if </ tt>および
    #＃<tt>：unless </ tt>）、クラスバージョンで利用可能
    # ＃+ validates_with +、代わりに+ validates +メソッドに配置する必要があります
    # ＃これらはコールバックで適用およびテストされるため。
    # ＃
    # ＃追加の構成オプションを渡すと、それらが渡されます
    # ＃クラスに追加し、+ options +として使用できます。
    # ＃詳細については、このメソッドのクラスバージョン。
    def validates_with(*args, &block)
      options = args.extract_options!
      options[:class] = self.class

      args.each do |klass|
        validator = klass.new(options, &block)
        validator.validate(self)
      end
    end
  end
end
