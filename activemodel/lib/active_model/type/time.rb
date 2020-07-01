# done

# frozen_string_literal: true

module ActiveModel
  module Type
    # オブジェクトの属性に型定義された時の処理をするためのClass
    class Time < Value # :nodoc:
      # Helpers::Timezone -> ~/activemodel/lib/active_model/type/helpers/timezone.rb
      # utcかそうでないかを判定するモジュール
      include Helpers::Timezone
      # 時間Valueの加工改変を行うモジュール
      include Helpers::TimeValue
      # Helpers::AcceptsMultiparameterTime.new -> ~/active_model/type/helpers/accepts_multiparameter_time.rb
      # マルチパラメータ時間を受け入れるモジュール。Hashだったらvalue_from_multiparameter_assignmentを起動させるためのモジュール
      # デフォルト時間を設定できる（引数を受け入れられる）ようインスタンスのそれをモジュールみたく使っている？？
      # DateTimeは日付を扱うので第4、第5引数（時間、分）の初期値が設定されている

      # こっちはデフォルトが2000年1月1日に設定されている？
      include Helpers::AcceptsMultiparameterTime.new(
        defaults: { 1 => 2000, 2 => 1, 3 => 1, 4 => 0, 5 => 0 }
      )

      def type
        :time
      end

      # 時間帯でのユーザー入力
      def user_input_in_time_zone(value)
        return unless value.present?

        # 時間帯を引数で設定できるメソッド。引数の値を調整してからmodule TimeValueのdef user_input_in_time_zoneに渡す
        case value
        when ::String
          value = "2000-01-01 #{value}"
          time_hash = ::Date._parse(value)
          return if time_hash[:hour].nil?
        when ::Time
          value = value.change(year: 2000, day: 1, month: 1)
        end

        super(value)
      end

      private
        def cast_value(value)
          # 文字列以外だったらコンマ調整したものをそのまま返す
          return apply_seconds_precision(value) unless value.is_a?(::String)
          return if value.empty?

          dummy_time_value = value.sub(/\A(\d\d\d\d-\d\d-\d\d |)/, "2000-01-01 ")

          # 文字列だったらfast_string_to_time。それもダメだったらダミー時間を返す。
          fast_string_to_time(dummy_time_value) || begin
            time_hash = ::Date._parse(dummy_time_value)
            return if time_hash[:hour].nil?
            new_time(*time_hash.values_at(:year, :mon, :mday, :hour, :min, :sec, :sec_fraction, :offset))
          end
        end
    end
  end
end
