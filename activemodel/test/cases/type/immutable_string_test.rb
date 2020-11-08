# done

# frozen_string_literal: true

require "cases/helper"

module ActiveModel
  module Type
    class ImmutableStringTest < ActiveModel::TestCase
      # テスト「キャスト文字列がフリーズ」する
      # テスト「不変文字列は出て来るのではない」

      test "cast strings are frozen" do
        s = "foo"
        type = Type::ImmutableString.new
        assert_equal true, type.cast(s).frozen?
      end

      test "immutable strings are not duped coming out" do
        # 値は等しい
        s = "foo"
        type = Type::ImmutableString.new
        assert_same s, type.cast(s)
        assert_same s, type.deserialize(s)
      end
    end
  end
end
