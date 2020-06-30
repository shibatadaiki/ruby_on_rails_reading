# frozen_string_literal: true

require "active_model/type/immutable_string"

module ActiveModel
  module Type
    class String < ImmutableString # :nodoc:
      # 二つの引数を比べている。別からきた値かどうかの確認？
      def changed_in_place?(raw_old_value, new_value)
        if new_value.is_a?(::String)
          raw_old_value != new_value
        end
      end

      private
        # 文字列変換。
        def cast_value(value)
          case value
          when ::String then ::String.new(value)
          when true then "t"
          when false then "f"
          else value.to_s
          end
        end
    end
  end
end
