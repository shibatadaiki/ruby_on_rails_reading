# frozen_string_literal: true

module ActiveModel
  module Type
    # オブジェクトの属性に型定義された時の処理をするためのClass
    class Date < Value # :nodoc:
      # Helpers::Timezone -> ~/activemodel/lib/active_model/type/helpers/timezone.rb
      # utcかそうでないかを判定するモジュール
      include Helpers::Timezone
      # Helpers::AcceptsMultiparameterTime.new -> ~/active_model/type/helpers/accepts_multiparameter_time.rb
      # マルチパラメータ時間を受け入れるモジュール。Hashだったらvalue_from_multiparameter_assignmentを起動させるためのモジュール
      # デフォルト時間を設定できる（引数を受け入れられる）ようインスタンスのそれをモジュールみたく使っている。
      # Dateは日付を扱うので第4、第5引数（時間、分）などは省略されている
      include Helpers::AcceptsMultiparameterTime.new

      # DateTimeとTimeにinclude Helpers::TimeValueがあってこちらにないのは時間がDateにないから

      # 各型クラスにある型名シンボル返すやつ
      def type
        :date
      end

      def type_cast_for_schema(value)
        # to_s(:db) -> 時間オブジェクトをいろいろな形に変換して返す
        # https://apidock.com/rails/ActiveSupport/TimeWithZone/to_s
        # inspect -> String
        # オブジェクトを人間が読める形式に変換した文字列を返します。
        # https://docs.ruby-lang.org/ja/latest/method/Object/i/inspect.html
        value.to_s(:db).inspect
      end

      private
        # 基本的に全ての型クラスにcast_valueが定義されており、cast_valueで各値の変換を行う
        def cast_value(value)
          if value.is_a?(::String)
            return if value.empty?
            # yyyy-mm-ddの形式で時間に変換できるかをまず試し、無理だったら文字列全体にParseをかける
            fast_string_to_date(value) || fallback_string_to_date(value)
          elsif value.respond_to?(:to_date)
            value.to_date
          else
            value
          end
        end

        ISO_DATE = /\A(\d{4})-(\d\d)-(\d\d)\z/
        # 日にちまでの高速文字列
        def fast_string_to_date(string)
          if string =~ ISO_DATE
            new_date $1.to_i, $2.to_i, $3.to_i
          end
        end

        # 現在日付までのフォールバック文字列
        def fallback_string_to_date(string)
          # https://docs.ruby-lang.org/ja/latest/method/Hash/i/values_at.html
          # 引数で指定されたキーに対応する値の配列を返します。
          # yy-mm-ddの部分を抽出して返す
          new_date(*::Date._parse(string, false).values_at(:year, :mon, :mday))
        end

        def new_date(year, mon, mday)
          unless year.nil? || (year == 0 && mon == 0 && mday == 0)
            # 引数からのDate生成に失敗したらnilを返す
            ::Date.new(year, mon, mday) rescue nil
          end
        end

        def value_from_multiparameter_assignment(*)
          # AcceptsMultiparameterTime.new.value_from_multiparameter_assignmentの結果がtrueなら
          # そこから出力された値のtime.year, time.mon, time.mdayでnew_dateメソッドを起動する
          time = super
          time && new_date(time.year, time.mon, time.mday)
        end
    end
  end
end
