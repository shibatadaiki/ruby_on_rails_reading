# done

# frozen_string_literal: true

module ActiveModel
  module Validations
    # 長さ検証
    class LengthValidator < EachValidator # :nodoc:
      # バリデーションメソッドのメッセージと処理の定数
      MESSAGES  = { is: :wrong_length, minimum: :too_short, maximum: :too_long }.freeze
      CHECKS    = { is: :==, minimum: :>=, maximum: :<= }.freeze

      # 予約済みオプション
      RESERVED_OPTIONS = [:minimum, :maximum, :within, :is, :too_short, :too_long]

      def initialize(options)
        if range = (options.delete(:in) || options.delete(:within))
          raise ArgumentError, ":in and :within must be a Range" unless range.is_a?(Range)
          options[:minimum], options[:maximum] = range.min, range.max
        end

        if options[:allow_blank] == false && options[:minimum].nil? && options[:is].nil?
          options[:minimum] = 1
        end

        super
      end

      # バリデーションの指定記述がそもそも成り立っているかの確認処理
      def check_validity!
        keys = CHECKS.keys & options.keys

        if keys.empty?
          # 範囲は指定されていません。 ：in、：within、：maximum、：minimum、または：isオプションを指定します。
          raise ArgumentError, "Range unspecified. Specify the :in, :within, :maximum, :minimum, or :is option."
        end

        keys.each do |key|
          value = options[key]

          unless (value.is_a?(Integer) && value >= 0) || value == Float::INFINITY || value.is_a?(Symbol) || value.is_a?(Proc)
            raise ArgumentError, ":#{key} must be a non-negative Integer, Infinity, Symbol, or Proc"
          end
        end
      end

      def validate_each(record, attribute, value)
        value_length = value.respond_to?(:length) ? value.length : value.to_s.length
        errors_options = options.except(*RESERVED_OPTIONS)

        # 指定されたバリデーション設定全てでvalueをチェックする
        CHECKS.each do |key, validity_check|
          # チェックするかチェック
          next unless check_value = options[key]

          if !value.nil? || skip_nil_check?(key)
            case check_value
            when Proc
              check_value = check_value.call(record)
            when Symbol
              check_value = record.send(check_value)
            end
            # value_length.send -> 3.>= check_value みたいになる
            next if value_length.send(validity_check, check_value)
          end

          errors_options[:count] = check_value

          default_message = options[MESSAGES[key]]
          errors_options[:message] ||= default_message if default_message

          record.errors.add(attribute, MESSAGES[key], **errors_options)
        end
      end

      private
        def skip_nil_check?(key)
          key == :maximum && options[:allow_nil].nil? && options[:allow_blank].nil?
        end
    end

    module HelperMethods
      # ＃指定された属性が長さ制限に一致することを検証します
      #       ＃提供されます。 一度に使用できる制約オプションは1つだけです。
      #       ＃+：minimum +および+：maximum +一緒に組み合わせることができます：
      #
      #   class Person < ActiveRecord::Base
      #     validates_length_of :first_name, maximum: 30
      #     validates_length_of :last_name, maximum: 30, message: "less than 30 if you don't mind"
      #     validates_length_of :fax, in: 7..32, allow_nil: true
      #     validates_length_of :phone, in: 7..32, allow_blank: true
      #     validates_length_of :user_name, within: 6..20, too_long: 'pick a shorter name', too_short: 'pick a longer name'
      #     validates_length_of :zip_code, minimum: 5, too_short: 'please enter at least 5 characters'
      #     validates_length_of :smurf_leader, is: 4, message: "papa is spelled with 4 characters... don't play me."
      #     validates_length_of :words_in_essay, minimum: 100, too_short: 'Your essay must be at least 100 words.'
      #
      #     private
      #
      #     def words_in_essay
      #       essay.scan(/\w+/)
      #     end
      #   end
      #
      #
      # ＃制約オプション：
      #      ＃
      #      ＃* <tt>：minimum </ tt>-属性の最小サイズ。
      #      ＃* <tt>：maximum </ tt>-属性の最大サイズ。 + nil +を許可
      #      ＃+：minimum +と併用しない場合のデフォルト。
      #      ＃* <tt>：is </ tt>-属性の正確なサイズ。
      #      ＃* <tt>：within </ tt>-の最小サイズと最大サイズを指定する範囲
      #      ＃属性。
      #      ＃* <tt>：in </ tt>-<tt>：within </ tt>の同義語（またはエイリアス）。
      #      ＃
      #      ＃ 別のオプション：
      #      ＃
      #      ＃* <tt>：allow_nil </ tt>-属性は+ nil +の場合があります。検証をスキップします。
      #      ＃* <tt>：allow_blank </ tt>-属性は空白の場合があります。検証をスキップします。
      #      ＃* <tt>：too_long </ tt>-属性が
      #      ＃最大（デフォルトは「長すぎる（最大は％{count}文字）」）。
      #      ＃* <tt>：too_short </ tt>-属性が下にある場合のエラーメッセージ
      #      ＃最小（デフォルトは「短すぎる（最小は％{count}文字）」）。
      #      ＃* <tt>：wrong_length </ tt>-<tt>：is </ tt>を使用している場合のエラーメッセージ
      #      ＃メソッドと属性のサイズが間違っている（デフォルトは「間違っている」
      #      ＃長さ（％{count}文字である必要があります） "）。
      #      ＃* <tt>：message </ tt>-<tt>：minimum </ tt>に使用するエラーメッセージ、
      #      ＃<tt>：maximum </ tt>、または<tt>：is </ tt>違反。適切なのエイリアス
      #      ＃<tt> too_long </ tt> / <tt> too_short </ tt> / <tt> wrong_length </ tt>メッセージ。
      #      ＃
      #      ＃すべてのバリデーターがサポートするデフォルトのオプションのリストもあります：
      #      ＃+：if +、+：unless +、+：on +および+：strict +。
      #      ＃詳細は、<tt> ActiveModel :: Validations＃validates </ tt>を参照してください
      def validates_length_of(*attr_names)
        validates_with LengthValidator, _merge_attributes(attr_names)
      end

      alias_method :validates_size_of, :validates_length_of
    end
  end
end
