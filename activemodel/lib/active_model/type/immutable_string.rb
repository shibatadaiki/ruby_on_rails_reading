# frozen_string_literal: true

module ActiveModel
  module Type
    # オブジェクトの属性に型定義された時の処理をするためのClass
    # 不変文字
    class ImmutableString < Value # :nodoc:
      def type
        :string
      end

      # 文字列変換。
      def serialize(value)
        case value
        when ::Numeric, ::Symbol, ActiveSupport::Duration then value.to_s
        when true then "t"
        when false then "f"
        else super
        end
      end

      private
        # 文字列変換と固定（不変文字のみ）。
        def cast_value(value)
          result = \
            case value
            when true then "t"
            when false then "f"
            else value.to_s
            end
          result.freeze
        end
    end
  end
end
