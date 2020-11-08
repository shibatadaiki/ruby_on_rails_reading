# done

# frozen_string_literal: true

require "active_support/core_ext/string/zones"
require "active_support/core_ext/time/zones"

module ActiveModel
  module Type
    module Helpers # :nodoc: all
      module TimeValue
        # 秒精度の適用を行った後、タイムゾーン設定をした時間を返す
        def serialize(value)
          value = apply_seconds_precision(value)

          # ~/activesupport/lib/active_support/core_ext/object/acts_like.rb
          # acts_like?で、引数とレシーバの型インスタンスが合致していることを確認できる
          # 「~のように振舞うか？」
          if value.acts_like?(:time)
            if is_utc?
              # https://docs.ruby-lang.org/ja/latest/class/Time.html#I_GETGM
              # タイムゾーンを協定世界時に設定した Time オブジェクトを新しく生成して返します。
              value = value.getutc if value.respond_to?(:getutc) && !value.utc?
            else
              # https://docs.ruby-lang.org/ja/latest/class/Time.html#I_GETGM
              # タイムゾーンを地方時に設定した Time オブジェクトを新しく生成して返します。
              value = value.getlocal if value.respond_to?(:getlocal)
            end
          end

          value
        end

        # 秒精度を適用する
        def apply_seconds_precision(value)
          # 精度値がないか、:nsecのシンボル（orメソッド？）が返ってこない場合、そのまま値を返す
          return value unless precision && value.respond_to?(:nsec)

          # 秒精度の適用
          number_of_insignificant_digits = 9 - precision
          round_power = 10**number_of_insignificant_digits
          rounded_off_nsec = value.nsec % round_power

          if rounded_off_nsec > 0
            value.change(nsec: value.nsec - rounded_off_nsec)
          else
            value
          end
        end

        # DB形式の値に変換して返す
        def type_cast_for_schema(value)
          value.to_s(:db).inspect
        end

        # 時間帯でのユーザー入力
        def user_input_in_time_zone(value)
          # ~/activesupport/lib/active_support/time_with_zone.rb につながる
          value.in_time_zone
        end

        private
          # 引数からの時間生成
          def new_time(year, mon, mday, hour, min, sec, microsec, offset = nil)
            # Treat 0000-00-00 00:00:00 as nil.
            return if year.nil? || (year == 0 && mon == 0 && mday == 0)

            if offset
              time = ::Time.utc(year, mon, mday, hour, min, sec, microsec) rescue nil
              return unless time

              time -= offset
              is_utc? ? time : time.getlocal
            else
              ::Time.public_send(default_timezone, year, mon, mday, hour, min, sec, microsec) rescue nil
            end
          end

          ISO_DATETIME = /\A(\d{4})-(\d\d)-(\d\d) (\d\d):(\d\d):(\d\d)(\.\d+)?\z/

          # Doesn't handle time zones.
          # タイムゾーンを扱いません。
          # 時間までの高速文字列
          # Time ClassとDateTime Classのcast_valueで使用される
          def fast_string_to_time(string)
            # 文字列を正規表現で分割して引数にとり、時間オブジェクトを生成する
            if string =~ ISO_DATETIME

              # コンマ秒の処理をする
              microsec_part = $7
              if microsec_part && microsec_part.start_with?(".") && microsec_part.length == 7
                microsec_part[0] = ""
                microsec = microsec_part.to_i
              else
                microsec = (microsec_part.to_r * 1_000_000).to_i
              end
              new_time $1.to_i, $2.to_i, $3.to_i, $4.to_i, $5.to_i, $6.to_i, microsec
            end
          end
      end
    end
  end
end
