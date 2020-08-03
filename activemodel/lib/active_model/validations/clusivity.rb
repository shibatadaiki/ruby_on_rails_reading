# done

# frozen_string_literal: true

require "active_support/core_ext/range"

module ActiveModel
  module Validations
    # 他の場所で使われる（importされる）モジュール
    module Clusivity #:nodoc:
      # validateに含まれる範囲系の処理。rangeで値の範囲の判定をする？

      # ERROR_MESSAGE = "メソッド#include？を持つオブジェクト、またはプロシージャ、ラムダ、またはシンボルが必要です、" \
      #                       "および構成ハッシュの：in（または：within）オプションとして指定する必要があります"
      ERROR_MESSAGE = "An object with the method #include? or a proc, lambda or symbol is required, " \
                      "and must be supplied as the :in (or :within) option of the configuration hash"

      def check_validity!
        unless delimiter.respond_to?(:include?) || delimiter.respond_to?(:call) || delimiter.respond_to?(:to_sym)
          raise ArgumentError, ERROR_MESSAGE
        end
      end

    private
      def include?(record, value)
        members = if delimiter.respond_to?(:call)
          delimiter.call(record)
        elsif delimiter.respond_to?(:to_sym)
          record.send(delimiter)
        else
          delimiter
        end

        # inclusion_methodで、各メソッド名のシンボルを返してsendで実行する
        # membersがRange（Numeric）オブジェならcover?メソッドで範囲の検査をする
        members.send(inclusion_method(members), value)
      end

      def delimiter
        @delimiter ||= options[:in] || options[:within]
      end

      # After Ruby 2.2, <tt>Range#include?</tt> on non-number-or-time-ish ranges checks all
      # possible values in the range for equality, which is slower but more accurate.
      # <tt>Range#cover?</tt> uses the previous logic of comparing a value with the range
      # endpoints, which is fast but is only accurate on Numeric, Time, Date,
      # or DateTime ranges.

      # ＃Ruby 2.2以降、<tt> Range＃include？</ tt>は、数値または時間の範囲以外の範囲ですべてをチェックします
      #       ＃同等性の範囲内の可能な値。低速ですがより正確です。
      #       ＃<tt> Range＃cover？</ tt>は、値を範囲と比較する以前のロジックを使用します
      #       ＃エンドポイント。高速ですが、数値、時間、日付、
      #       ＃またはDateTimeの範囲。
      def inclusion_method(enumerable)
        if enumerable.is_a? Range
          case enumerable.first
          when Numeric, Time, DateTime, Date
            :cover?
          else
            :include?
          end
        else
          :include?
        end
      end
    end
  end
end
