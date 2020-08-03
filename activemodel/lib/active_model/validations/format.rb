# done

# frozen_string_literal: true

module ActiveModel
  module Validations
    # 正規表現のバリデーション
    class FormatValidator < EachValidator # :nodoc:
      def validate_each(record, attribute, value)
        if options[:with]
          regexp = option_call(record, :with)
          # unless regexp.match? -> 正規表現が含まれていればエラー
          record_error(record, attribute, :with, value) unless regexp.match?(value.to_s)
        elsif options[:without]
          regexp = option_call(record, :without)
          # if regexp.match? -> 正規表現が含まれていなければエラー
          record_error(record, attribute, :without, value) if regexp.match?(value.to_s)
        end
      end

      def check_validity!
        unless options.include?(:with) ^ options.include?(:without)  # ^ == xor, or "exclusive or"
          raise ArgumentError, "Either :with or :without must be supplied (but not both)"
        end

        check_options_validity :with
        check_options_validity :without
      end

      private
        def option_call(record, name)
          option = options[name]
          option.respond_to?(:call) ? option.call(record) : option
        end

        def record_error(record, attribute, name, value)
          record.errors.add(attribute, :invalid, **options.except(name).merge!(value: value))
        end

        def check_options_validity(name)
          if option = options[name]
            if option.is_a?(Regexp)
              if options[:multiline] != true && regexp_using_multiline_anchors?(option)
                raise ArgumentError, "The provided regular expression is using multiline anchors (^ or $), " \
                "which may present a security risk. Did you mean to use \\A and \\z, or forgot to add the " \
                ":multiline => true option?"
              #  指定された正規表現は複数行のアンカー（^または$）、 "\を使用しています
              #                 "これはセキュリティ上のリスクをもたらす可能性があります。\\ Aと\\ zを使用するつもりでしたか、それとも" \
              #                 "：multiline => trueオプション？
              end
            elsif !option.respond_to?(:call)
              # 正規表現またはプロシージャまたはラムダは、次のように指定する必要があります
              raise ArgumentError, "A regular expression or a proc or lambda must be supplied as :#{name}"
            end
          end
        end

        def regexp_using_multiline_anchors?(regexp)
          source = regexp.source
          source.start_with?("^") || (source.end_with?("$") && !source.end_with?("\\$"))
        end
    end

    module HelperMethods
      #＃指定された属性の値が正しいかどうかを検証します
      #＃フォーム、提供された正規表現による。 あなたは
      #＃属性は正規表現に一致します：
      #
      #   class Person < ActiveRecord::Base
      #     validates_format_of :email, with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, on: :create
      #   end
      #
      #＃または、指定した属性が_しない_ことを要求できます
      #＃正規表現に一致：
      #
      #   class Person < ActiveRecord::Base
      #     validates_format_of :email, without: /NOSPAM/
      #   end
      #
      #＃定期的に決定するプロシージャまたはラムダを提供することもできます
      #＃属性の検証に使用される式。
      #
      #   class Person < ActiveRecord::Base
      #     # 管理者は、スクリーン名の最初の文字に数字を含めることができます
      #     validates_format_of :screen_name,
      #                         with: ->(person) { person.admin? ? /\A[a-z0-9][a-z0-9_\-]*\z/i : /\A[a-z][a-z0-9_\-]*\z/i }
      #   end
      #
      #＃注：<tt> \ A </ tt>と<tt> \ z </ tt>を使用して、
      #＃文字列、<tt> ^ </ tt>および<tt> $ </ tt>は、行の開始/終了と一致します。
      #＃
      #＃<tt> ^ </ tt>と<tt> $ </ tt>の頻繁な誤用により、パスする必要があります
      #＃<tt> multiline：true </ tt>オプション（これら2つのいずれかを使用する場合）
      #＃提供された正規表現のアンカー。ほとんどの場合、
      #＃<tt> \ A </ tt>および<tt> \ z </ tt>を使用します。
      #＃
      #＃オプションとして<tt>：with </ tt>または<tt>：without </ tt>を渡す必要があります。
      #＃さらに、両方とも正規表現か、プロシージャまたはラムダでなければなりません。
      #＃そうでなければ、例外が発生します。
      #＃
      #＃設定オプション：
      #＃* <tt>：message </ tt>-カスタムエラーメッセージ（デフォルトは「is invalid」です）。
      #＃* <tt>：with </ tt>-属性が一致した場合に正規表現
      #＃検証が成功します。これはprocまたは
      #＃実行時に呼び出される正規表現を返すラムダ。
      #＃* <tt>：without </ tt>-属性がそうでない場合の正規表現
      #＃一致すると、検証が成功します。これは、
      #＃呼び出される正規表現を返すprocまたはlambda
      #＃ランタイム。
      #＃* <tt>：multiline </ tt>-正規表現に含まれる場合はtrueに設定します
      #＃ではなく、行の先頭または末尾に一致するアンカー
      #＃文字列の最初または最後。これらのアンカーは<tt> ^ </ tt>と<tt> $ </ tt>です。
      #＃
      #＃すべてのバリデーターがサポートするデフォルトのオプションのリストもあります：
      #＃+：if +、+：unless +、+：on +、+：allow_nil +、+：allow_blank +、+：strict +。
      #＃詳細は、<tt> ActiveModel :: Validations＃validates </ tt>を参照してください
      def validates_format_of(*attr_names)
        validates_with FormatValidator, _merge_attributes(attr_names)
      end
    end
  end
end
