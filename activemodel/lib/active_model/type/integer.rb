# frozen_string_literal: true

module ActiveModel
  module Type
    # オブジェクトの属性に型定義された時の処理をするためのClass
    # 整数
    class Integer < Value # :nodoc:
      include Helpers::Numeric

      # Column storage size in bytes.
      # 4 bytes means an integer as opposed to smallint etc.
      # ＃列ストレージサイズ（バイト単位）。
      # ＃4バイトは、smallintなどではなく整数を意味します。
      DEFAULT_LIMIT = 4
      # https://qiita.com/super-mana-chan/items/ca728d90db7c53295b15
      # *と記述することで受け取った引数を無視するようにも使用できます。
      #
      # superに渡される過剰な引数を無視している？
      def initialize(*, **)
        super
        @range = min_value...max_value
      end

      # 各型クラスにある型名シンボル返すやつ
      def type
        :integer
      end

      # deserialize（オブジェクトの型に復元）すること。
      def deserialize(value)
        return if value.blank?
        value.to_i
      end

      # 「シリアライズ（serialize）とは、プログラミングでオプジェクト化されたデータを、
      # ファイルやストレージに保存したり、ネットワークで送受信したりできるような形に変換することを言います。」
      def serialize(value)
        # 数値じゃない文字列だったらそのまま返す
        return if value.is_a?(::String) && non_numeric_string?(value)
        ensure_in_range(super)
      end

      private
        attr_reader :range

        # deserializeとの差がよくわからない。。
        # cast_valueはprivateメソッドだからValueクラスのcastメソッドから遠回りして呼び出される？
        def cast_value(value)
          value.to_i rescue nil
        end

        def ensure_in_range(value)
          # https://docs.ruby-lang.org/ja/2.0.0/method/Range/i/cover=3f.html
          # obj が範囲内に含まれている時に真を返します。
          if value && !range.cover?(value)
            # valueの数値がrange範囲内に含まれていなかったらActiveModel::RangeError
            raise ActiveModel::RangeError, "#{value} is out of range for #{self.class} with limit #{_limit} bytes"
          end
          value
        end

        # irb(main):001:0> _limit = 4
        # irb(main):002:0> 1 << (_limit * 8 - 1)
        # => 2147483648
        # irb(main):003:0> _limit = 2
        # irb(main):004:0> 1 << (_limit * 8 - 1)
        # => 32768
        def max_value
          # シフト演算子。bits だけビットを左にシフトします。
          1 << (_limit * 8 - 1) # 8 bits per byte with one bit for sign # 符号用に1ビットのバイトあたり8ビット
        end

        # max_valueの逆が最低値
        def min_value
          -max_value
        end

        # limitはValueクラスに定義されている属性
        def _limit
          limit || DEFAULT_LIMIT
        end
    end
  end
end
