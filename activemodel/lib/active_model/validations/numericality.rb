# done

# frozen_string_literal: true

require "bigdecimal/util"

module ActiveModel
  module Validations
    # 数字バリデーション
    class NumericalityValidator < EachValidator # :nodoc:
      CHECKS = { ,
                 equal_to: :==, less_than: :<, less_than_or_equal_to: :<=,
                 odd: :odd?, even: :even?, other_than: :!= }.freeze

      RESERVED_OPTIONS = CHECKS.keys + [:only_integer]

      INTEGER_REGEX = /\A[+-]?\d+\z/

      def check_validity!
        keys = CHECKS.keys - [:odd, :even]
        # 引数エラーチェック
        options.slice(*keys).each do |option, value|
          unless value.is_a?(Numeric) || value.is_a?(Proc) || value.is_a?(Symbol)
            raise ArgumentError, ":#{option} must be a number, a symbol or a proc"
          end
        end
      end

      def validate_each(record, attr_name, value, precision: Float::DIG, scale: nil)
        came_from_user = :"#{attr_name}_came_from_user?"

        if record.respond_to?(came_from_user)
          if record.public_send(came_from_user)
            raw_value = record.read_attribute_before_type_cast(attr_name)
          elsif record.respond_to?(:read_attribute)
            raw_value = record.read_attribute(attr_name)
          end
        else
          before_type_cast = :"#{attr_name}_before_type_cast"
          if record.respond_to?(before_type_cast)
            raw_value = record.public_send(before_type_cast)
          end
        end
        raw_value ||= value

        if record_attribute_changed_in_place?(record, attr_name)
          raw_value = value
        end

        # 指定された属性の値が数値であるかどうかを検証
        unless is_number?(raw_value, precision, scale)
          record.errors.add(attr_name, :not_a_number, **filtered_options(raw_value))
          return
        end

        if allow_only_integer?(record) && !is_integer?(raw_value)
          record.errors.add(attr_name, :not_an_integer, **filtered_options(raw_value))
          return
        end

        value = parse_as_number(raw_value, precision, scale)

        # 指定された属性の値が数値であるか以降のオプションチェック
        options.slice(*CHECKS.keys).each do |option, option_value|
          case option
          when :odd, :even
            # send -> odd: :odd?, even: :even?
            unless value.to_i.send(CHECKS[option])
              record.errors.add(attr_name, option, **filtered_options(value))
            end
          else
            case option_value
            when Proc
              # option_value.call(record) -> ユーザーが指定したオプションブロックを実行
              option_value = option_value.call(record)
            when Symbol
              # send(option_value) -> greater_than: :>, greater_than_or_equal_to: :>=などを実行
              option_value = record.send(option_value)
            end

            option_value = parse_as_number(option_value, precision, scale)

            # send -> その他オプション
            unless value.send(CHECKS[option], option_value)
              record.errors.add(attr_name, option, **filtered_options(value).merge!(count: option_value))
            end
          end
        end
      end

    private
      #　指定された度数の数字に変換
      def parse_as_number(raw_value, precision, scale)
        if raw_value.is_a?(Float)
          parse_float(raw_value, precision, scale)
        elsif raw_value.is_a?(Numeric)
          raw_value
        elsif is_integer?(raw_value)
          raw_value.to_i
        elsif !is_hexadecimal_literal?(raw_value)
          parse_float(Kernel.Float(raw_value), precision, scale)
        end
      end

      def parse_float(raw_value, precision, scale)
        (scale ? raw_value.truncate(scale) : raw_value).to_d(precision)
      end

      def is_number?(raw_value, precision, scale)
        !parse_as_number(raw_value, precision, scale).nil?
      rescue ArgumentError, TypeError
        false
      end

      def is_integer?(raw_value)
        INTEGER_REGEX.match?(raw_value.to_s)
      end

      def is_hexadecimal_literal?(raw_value)
        /\A0[xX]/.match?(raw_value.to_s)
      end

      def filtered_options(value)
        filtered = options.except(*RESERVED_OPTIONS)
        filtered[:value] = value
        filtered
      end

      # Symbol, Procであれば指定の任意処理を実行
      def allow_only_integer?(record)
        case options[:only_integer]
        when Symbol
          record.send(options[:only_integer])
        when Proc
          options[:only_integer].call(record)
        else
          options[:only_integer]
        end
      end

      def record_attribute_changed_in_place?(record, attr_name)
        record.respond_to?(:attribute_changed_in_place?) &&
          record.attribute_changed_in_place?(attr_name.to_s)
      end
    end

    module HelperMethods
      # ＃指定された属性の値が数値であるかどうかを検証します
      #       ＃Kernel.Floatでフロートに変換しようとしている（<tt> only_integer </ tt>の場合）
      #       ＃は+ false +）または正規表現に適用<tt> / \ A [\ + \-]？\ d + \ z / </ tt>
      #       ＃（<tt> only_integer </ tt>が+ true +に設定されている場合）。 Kernel.Float値の精度
      #       ＃は15桁まで保証されます。
      #
      #   class Person < ActiveRecord::Base
      #     validates_numericality_of :value, on: :create
      #   end
      #
      # ＃設定オプション：
      #      ＃* <tt>：message </ tt>-カスタムエラーメッセージ（デフォルトは「is not a number」です）。
      #      ＃* <tt>：only_integer </ tt>-値が
      #      ＃整数、例えば整数値（デフォルトは+ false +）。
      #      ＃* <tt>：allow_nil </ tt>-属性が+ nil +の場合、検証をスキップします（デフォルトは
      #      ＃+ false +）。 Integer列とFloat列の場合、空の文字列は
      #      ＃+ nil +に変換されます。
      #      ＃* <tt>：greater_than </ tt>-値が
      #      ＃指定された値。
      #      ＃* <tt>：greater_than_or_equal_to </ tt>-値が
      #      ＃指定された値以上。
      #      ＃* <tt>：equal_to </ tt>-値が指定された値と等しくなければならないことを指定します
      #      ＃値。
      #      ＃* <tt>：less_than </ tt>-値が
      #      ＃指定された値。
      #      ＃* <tt>：less_than_or_equal_to </ tt>-値を小さくする必要があることを指定します
      #      ＃指定された値以上。
      #      ＃* <tt>：other_than </ tt>-値が
      #      ＃指定された値。
      #      ＃* <tt>：odd </ tt>-値が奇数でなければならないことを指定します。
      #      ＃* <tt>：even </ tt>-値が偶数でなければならないことを指定します。
      #      ＃
      #      ＃すべてのバリデーターがサポートするデフォルトのオプションのリストもあります：
      #      ＃+：if +、+：unless +、+：on +、+：allow_nil +、+：allow_blank +、+：strict +。
      #      ＃詳細は、<tt> ActiveModel :: Validations＃validates </ tt>を参照してください
      #      ＃
      #      ＃次のチェックは、プロシージャまたはシンボルで提供することもできます。
      #      ＃メソッドに対応：
      #      ＃
      #      ＃* <tt>：greater_than </ tt>
      #      ＃* <tt>：greater_than_or_equal_to </ tt>
      #      ＃* <tt>：equal_to </ tt>
      #      ＃* <tt>：less_than </ tt>
      #      ＃* <tt>：less_than_or_equal_to </ tt>
      #      ＃* <tt>：only_integer </ tt>
      #
      # For example:
      #
      #   class Person < ActiveRecord::Base
      #     validates_numericality_of :width, less_than: ->(person) { person.height }
      #     validates_numericality_of :width, greater_than: :minimum_weight
      #   end
      def validates_numericality_of(*attr_names)
        validates_with NumericalityValidator, _merge_attributes(attr_names)
      end
    end
  end
end
