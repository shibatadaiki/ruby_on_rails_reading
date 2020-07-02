# frozen_string_literal: true

module ActiveModel
  module Type
    module Helpers # :nodoc: all
      # 数値ヘルパー
      module Numeric
        def serialize(value)
          cast(value)
        end

        # T/F とStringの存在値を出力
        def cast(value)
          value = \
            case value
            when true then 1
            when false then 0
            when ::String then value.presence
            else value
            end
          super(value)
        end

        # superのメソッドで検知できなかったらnumber_to_non_number?で確認
        def changed?(old_value, _new_value, new_value_before_type_cast) # :nodoc:
          super || number_to_non_number?(old_value, new_value_before_type_cast)
        end

        private
          # 数値じゃない文字列だったら（0になるから）変化しているとみなしてtrueを返す？
          def number_to_non_number?(old_value, new_value_before_type_cast)
            old_value != nil && non_numeric_string?(new_value_before_type_cast.to_s)
          end

          # 非数値文字列？
          def non_numeric_string?(value)
            # 'wibble'.to_i will give zero, we want to make sure
            # that we aren't marking int zero to string zero as
            # changed.
            # ＃ 'wibble'.to_iはゼロを与えるので、確認したい
            # ＃ int 0をstring zeroにマークしていないこと
            # ＃ かわった。
            !NUMERIC_REGEX.match?(value)
          end

          NUMERIC_REGEX = /\A\s*[+-]?\d/
          private_constant :NUMERIC_REGEX
      end
    end
  end
end
