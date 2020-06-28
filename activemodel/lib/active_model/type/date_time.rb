# frozen_string_literal: true

module ActiveModel
  module Type
    class DateTime < Value # :nodoc:
      # Helpers::Timezone -> ~/activemodel/lib/active_model/type/helpers/timezone.rb
      # utcかそうでないかを判定するモジュール
      include Helpers::Timezone
      include Helpers::TimeValue
      # Helpers::AcceptsMultiparameterTime.new -> ~/active_model/type/helpers/accepts_multiparameter_time.rb
      # マルチパラメータ時間を受け入れるモジュール。Hashだったらvalue_from_multiparameter_assignmentを起動させるためのモジュール
      # デフォルト時間を設定できる（引数を受け入れられる）ようインスタンスのそれをモジュールみたく使っている？？
      # DateTimeは日付を扱うので第4、第5引数（時間、分）の初期値が設定されている
      include Helpers::AcceptsMultiparameterTime.new(
        defaults: { 4 => 0, 5 => 0 }
      )

      def type
        :datetime
      end

      private
        def cast_value(value)
          return apply_seconds_precision(value) unless value.is_a?(::String)
          return if value.empty?

          fast_string_to_time(value) || fallback_string_to_time(value)
        end

        # '0.123456' -> 123456
        # '1.123456' -> 123456
        def microseconds(time)
          time[:sec_fraction] ? (time[:sec_fraction] * 1_000_000).to_i : 0
        end

        def fallback_string_to_time(string)
          time_hash = ::Date._parse(string)
          time_hash[:sec_fraction] = microseconds(time_hash)

          new_time(*time_hash.values_at(:year, :mon, :mday, :hour, :min, :sec, :sec_fraction, :offset))
        end

        def value_from_multiparameter_assignment(values_hash)
          missing_parameters = (1..3).select { |key| !values_hash.key?(key) }
          if missing_parameters.any?
            raise ArgumentError, "Provided hash #{values_hash} doesn't contain necessary keys: #{missing_parameters}"
          end
          super
        end
    end
  end
end
