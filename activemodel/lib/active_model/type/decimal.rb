# done

# frozen_string_literal: true

require "bigdecimal/util"

module ActiveModel
  module Type
    # オブジェクトの属性に型定義された時の処理をするためのClass
    # 少数
    class Decimal < Value # :nodoc:
      include Helpers::Numeric
      # 最大精度
      BIGDECIMAL_PRECISION = 18

      def type
        :decimal
      end

      def type_cast_for_schema(value)
        value.to_s.inspect
      end

      private
        # cast_valueはprivateメソッドだからValueクラスのcastメソッドから遠回りして呼び出される？
        # Decimal / BigDecimalに変換
        def cast_value(value)
          casted_value = \
            case value
            # Float値だったらbig_decimal値に変換してから丸め込む
            when ::Float
              convert_float_to_big_decimal(value)
            when ::Numeric
              BigDecimal(value, precision || BIGDECIMAL_PRECISION)
            when ::String
              begin
                value.to_d
              rescue ArgumentError
                BigDecimal(0)
              end
            else
              if value.respond_to?(:to_d)
                value.to_d
              else
                # to_dできなかったら文字列に直してcast_valueし直す
                cast_value(value.to_s)
              end
            end

          # scaleの精度で丸め込む
          apply_scale(casted_value)
        end

        def convert_float_to_big_decimal(value)
          # precision値があればBigDecimalの値に変換
          if precision
            BigDecimal(apply_scale(value), float_precision)
          else
            value.to_d
          end
        end

        def float_precision
          # 精度が細かすぎたら調整する？
          if precision.to_i > ::Float::DIG + 1
            ::Float::DIG + 1
          else
            precision.to_i
          end
        end

        def apply_scale(value)
          # scaleの精度で丸め込む
          if scale
            value.round(scale)
          else
            value
          end
        end
    end
  end
end
