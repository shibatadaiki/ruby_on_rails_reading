# frozen_string_literal: true

module ActiveModel
  module Type
    # Date型だったら文字列型に変換する機能を追加
    class Binary < Value # :nodoc:
      def type
        :binary
      end

      def binary?
        true
      end

      def cast(value)
        if value.is_a?(Data)
          value.to_s
        else
          super
        end
      end

      def serialize(value)
        return if value.nil?
        Data.new(super)
      end

      def changed_in_place?(raw_old_value, value)
        old_value = deserialize(raw_old_value)
        old_value != value
      end

      class Data # :nodoc:
        def initialize(value)
          @value = value.to_s
        end

        def to_s
          @value
        end
        alias_method :to_str, :to_s

        def hex
          # https://docs.ruby-lang.org/ja/latest/method/String/i/unpack1.html
          # 書式文字列に従ってstr（バイナリデータを含む場合があります）をデコードし、最初に抽出された値を返します。
          @value.unpack1("H*")
        end

        def ==(other)
          other == to_s || super
        end
      end
    end
  end
end
