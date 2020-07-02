# done

# frozen_string_literal: true

#　       「単純な値」をテストする
#       「nilにキャストされたランダムオブジェクト」をテストする
#       「to_iなしでオブジェクトをキャストする」テスト
#       「キャスティングナンとインフィニティ」のテスト
#       「データベースのブール値をキャストする」テスト
#       「キャスト時間」をテストする
#       「データベースのキャスト文字列」をテストします
#       「空の文字列をキャストする」テスト
#       「変更されましたか？」 行う
#       テスト「int最小値未満の値は範囲外です」
#       テスト「int最大値を超える値は範囲外です」
#       「非常に小さな数は範囲外」のテスト
#       「非常に大きな数は範囲外」のテスト
#       「通常の数値は範囲内にある」テスト
#       「int最大値が範囲内にある」テスト
#       「int最小値が範囲内にある」テスト
#       「制限が大きい列の範囲が大きい」というテスト

require "cases/helper"
require "active_support/core_ext/numeric/time"

module ActiveModel
  module Type
    class IntegerTest < ActiveModel::TestCase
      test "simple values" do
        type = Type::Integer.new
        assert_nil type.cast("")
        assert_equal 1, type.cast(1)
        assert_equal 1, type.cast("1")
        assert_equal 1, type.cast("1ignore")
        assert_equal 0, type.cast("bad1")
        assert_equal 0, type.cast("bad")
        assert_equal 1, type.cast(1.7)
        assert_equal 0, type.cast(false)
        assert_equal 1, type.cast(true)
        assert_nil type.cast(nil)
      end

      test "random objects cast to nil" do
        type = Type::Integer.new
        assert_nil type.cast([1, 2])
        assert_nil type.cast(1 => 2)
        assert_nil type.cast(1..2)
      end

      test "casting objects without to_i" do
        type = Type::Integer.new
        assert_nil type.cast(::Object.new)
      end

      test "casting nan and infinity" do
        type = Type::Integer.new
        assert_nil type.cast(::Float::NAN)
        assert_nil type.cast(1.0 / 0.0)
      end

      test "casting booleans for database" do
        type = Type::Integer.new
        assert_equal 1, type.serialize(true)
        assert_equal 0, type.serialize(false)
      end

      test "casting duration" do
        type = Type::Integer.new
        assert_equal 1800, type.cast(30.minutes)
        assert_equal 7200, type.cast(2.hours)
      end

      test "casting string for database" do
        type = Type::Integer.new
        assert_nil type.serialize("wibble")
        assert_equal 5, type.serialize("5wibble")
        assert_equal 5, type.serialize(" +5")
        assert_equal(-5, type.serialize(" -5"))
      end

      test "casting empty string" do
        type = Type::Integer.new
        assert_nil type.cast("")
        assert_nil type.serialize("")
        assert_nil type.deserialize("")
      end

      test "changed?" do
        type = Type::Integer.new

        # 値を完全に書き換えたらchanged?
        assert type.changed?(0, 0, "wibble")
        assert type.changed?(5, 0, "wibble")
        # 値自体がそのままであれば!changed?
        assert_not type.changed?(5, 5, "5wibble")
        assert_not type.changed?(5, 5, "5")
        assert_not type.changed?(5, 5, "5.0")
        assert_not type.changed?(5, 5, "+5")
        assert_not type.changed?(5, 5, "+5.0")
        assert_not type.changed?(-5, -5, "-5")
        assert_not type.changed?(-5, -5, "-5.0")
        assert_not type.changed?(nil, nil, nil)
      end

      test "values below int min value are out of range" do
        assert_raises(ActiveModel::RangeError) do
          Integer.new.serialize(-2147483649)
        end
      end

      test "values above int max value are out of range" do
        assert_raises(ActiveModel::RangeError) do
          Integer.new.serialize(2147483648)
        end
      end

      test "very small numbers are out of range" do
        assert_raises(ActiveModel::RangeError) do
          Integer.new.serialize(-9999999999999999999999999999999)
        end
      end

      test "very large numbers are out of range" do
        assert_raises(ActiveModel::RangeError) do
          Integer.new.serialize(9999999999999999999999999999999)
        end
      end

      test "normal numbers are in range" do
        type = Integer.new
        assert_equal(0, type.serialize(0))
        assert_equal(-1, type.serialize(-1))
        assert_equal(1, type.serialize(1))
      end

      test "int max value is in range" do
        assert_equal(2147483647, Integer.new.serialize(2147483647))
      end

      test "int min value is in range" do
        assert_equal(-2147483648, Integer.new.serialize(-2147483648))
      end

      test "columns with a larger limit have larger ranges" do
        type = Integer.new(limit: 8)

        assert_equal(9223372036854775807, type.serialize(9223372036854775807))
        assert_equal(-9223372036854775808, type.serialize(-9223372036854775808))
        assert_raises(ActiveModel::RangeError) do
          type.serialize(-9999999999999999999999999999999)
        end
        assert_raises(ActiveModel::RangeError) do
          type.serialize(9999999999999999999999999999999)
        end
      end
    end
  end
end
