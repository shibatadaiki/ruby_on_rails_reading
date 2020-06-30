# frozen_string_literal: true

require "cases/helper"

#テスト "from_database +データベースからの型キャストの読み取り"
#テスト "from_user +ユーザーからの型キャストを読み取る"
#テスト「読み取りは値を記憶する」
#テストは「読み取りは偽の値を記憶する」を行う
#テスト「read_before_typecastは指定された値を返します」
#「from_database + read_for_databaseタイプのデータベースへのキャストおよびデータベースからのキャスト」をテストします。
#「from_user + read_for_databaseタイプキャストをユーザーからデータベースにキャストする」テスト
#テスト "値を複製する"を行う
#テスト「値を複製できない場合、値を複製しても値は複製されません」
#テスト「型キャストをまだ行っていない場合、ダッピングは熱心に型キャストを行わない」
#テスト「with_value_from_userは、ユーザーからの値を持つ新しい属性を返します」
#テスト "with_value_from_databaseはデータベースからの値を持つ新しい属性を返します"
#テスト「ブロックが値に与えられた場合、初期化されていない属性はその名前を生成します」
#テスト「初期化されていない属性には値がありません」
#「属性が同じコンストラクター引数を持つ他の属性と等しい」テスト
#「属性が異なる名前の属性と等しくない」テスト
#「属性が異なるタイプの属性と等しくない」テスト
#「属性は異なる値の属性と等しくない」テスト
#「属性が他のクラスの属性と等しくない」テスト
#テスト「デフォルトでは属性は読み込まれていません」
#テスト「値が計算されたときに属性が読み込まれた」
#テスト「属性が割り当てられていないか変更されていない場合、属性は変更されません」
#「新しい値が割り当てられると、属性が変更される」テスト
#テスト「同じ値が割り当てられている場合、属性は変更されません」
#テスト 読み取られていない属性は変更できません。そして、高価な計算をスキップします」
#「属性が変更されている場合、属性が変更される」テスト
#「属性は変更を忘れることができる」テスト
#「with_value_from_userが値を検証する」テスト
#「with_typeは変異を保持する」テスト

module ActiveModel
  class AttributeTest < ActiveModel::TestCase
    setup do
      # https://qiita.com/koshilife/items/dcb1fc7ac0c4a676c17c
      @type = Minitest::Mock.new
    end

    teardown do
      assert @type.verify
    end

    test "from_database + read type casts from database" do

      # 第一引数にコールされるメソッド名, 第二引数に返却値, 第三引数にメソッドコール時に指定する引数
      #
      # deserializeは文字列からオブジェクトを復元する処理
      @type.expect(:deserialize, "type cast from database", ["a value"])
      attribute = Attribute.from_database(nil, "a value", @type)

      type_cast_value = attribute.value

      assert_equal "type cast from database", type_cast_value
    end

    test "from_user + read type casts from user" do
      @type.expect(:cast, "type cast from user", ["a value"])
      attribute = Attribute.from_user(nil, "a value", @type)

      type_cast_value = attribute.value

      assert_equal "type cast from user", type_cast_value
    end

    test "reading memoizes the value" do
      @type.expect(:deserialize, "from the database", ["whatever"])
      attribute = Attribute.from_database(nil, "whatever", @type)

      type_cast_value = attribute.value
      second_read = attribute.value

      assert_equal "from the database", type_cast_value
      assert_same type_cast_value, second_read
    end

    test "reading memoizes falsy values" do
      @type.expect(:deserialize, false, ["whatever"])
      attribute = Attribute.from_database(nil, "whatever", @type)

      attribute.value
      attribute.value
    end

    test "read_before_typecast returns the given value" do
      attribute = Attribute.from_database(nil, "raw value", @type)

      raw_value = attribute.value_before_type_cast

      assert_equal "raw value", raw_value
    end

    test "from_database + read_for_database type casts to and from database" do
      @type.expect(:deserialize, "read from database", ["whatever"])
      @type.expect(:serialize, "ready for database", ["read from database"])
      attribute = Attribute.from_database(nil, "whatever", @type)

      serialize = attribute.value_for_database

      assert_equal "ready for database", serialize
    end

    test "from_user + read_for_database type casts from the user to the database" do
      @type.expect(:cast, "read from user", ["whatever"])
      @type.expect(:serialize, "ready for database", ["read from user"])
      attribute = Attribute.from_user(nil, "whatever", @type)

      serialize = attribute.value_for_database

      assert_equal "ready for database", serialize
    end

    test "duping dups the value" do
      @type.expect(:deserialize, +"type cast", ["a value"])
      attribute = Attribute.from_database(nil, "a value", @type)

      value_from_orig = attribute.value
      value_from_clone = attribute.dup.value
      value_from_orig << " foo"

      assert_equal "type cast foo", value_from_orig
      assert_equal "type cast", value_from_clone
    end

    test "duping does not dup the value if it is not dupable" do
      @type.expect(:deserialize, false, ["a value"])
      attribute = Attribute.from_database(nil, "a value", @type)

      assert_same attribute.value, attribute.dup.value
    end

    test "duping does not eagerly type cast if we have not yet type cast" do
      attribute = Attribute.from_database(nil, "a value", @type)
      attribute.dup
    end

    class MyType
      def cast(value)
        value + " from user"
      end

      def deserialize(value)
        value + " from database"
      end

      def assert_valid_value(*)
      end
    end

    test "with_value_from_user returns a new attribute with the value from the user" do
      old = Attribute.from_database(nil, "old", MyType.new)
      new = old.with_value_from_user("new")

      assert_equal "old from database", old.value
      assert_equal "new from user", new.value
    end

    test "with_value_from_database returns a new attribute with the value from the database" do
      old = Attribute.from_user(nil, "old", MyType.new)
      new = old.with_value_from_database("new")

      assert_equal "old from user", old.value
      assert_equal "new from database", new.value
    end

    test "uninitialized attributes yield their name if a block is given to value" do
      block = proc { |name| name.to_s + "!" }
      foo = Attribute.uninitialized(:foo, nil)
      bar = Attribute.uninitialized(:bar, nil)

      assert_equal "foo!", foo.value(&block)
      assert_equal "bar!", bar.value(&block)
    end

    test "uninitialized attributes have no value" do
      assert_nil Attribute.uninitialized(:foo, nil).value
    end

    test "attributes equal other attributes with the same constructor arguments" do
      first = Attribute.from_database(:foo, 1, Type::Integer.new)
      second = Attribute.from_database(:foo, 1, Type::Integer.new)
      assert_equal first, second
    end

    test "attributes do not equal attributes with different names" do
      first = Attribute.from_database(:foo, 1, Type::Integer.new)
      second = Attribute.from_database(:bar, 1, Type::Integer.new)
      assert_not_equal first, second
    end

    test "attributes do not equal attributes with different types" do
      first = Attribute.from_database(:foo, 1, Type::Integer.new)
      second = Attribute.from_database(:foo, 1, Type::Float.new)
      assert_not_equal first, second
    end

    test "attributes do not equal attributes with different values" do
      first = Attribute.from_database(:foo, 1, Type::Integer.new)
      second = Attribute.from_database(:foo, 2, Type::Integer.new)
      assert_not_equal first, second
    end

    test "attributes do not equal attributes of other classes" do
      first = Attribute.from_database(:foo, 1, Type::Integer.new)
      second = Attribute.from_user(:foo, 1, Type::Integer.new)
      assert_not_equal first, second
    end

    test "an attribute has not been read by default" do
      attribute = Attribute.from_database(:foo, 1, Type::Value.new)
      assert_not_predicate attribute, :has_been_read?
    end

    test "an attribute has been read when its value is calculated" do
      attribute = Attribute.from_database(:foo, 1, Type::Value.new)
      attribute.value
      assert_predicate attribute, :has_been_read?
    end

    test "an attribute is not changed if it hasn't been assigned or mutated" do
      attribute = Attribute.from_database(:foo, 1, Type::Value.new)

      assert_not_predicate attribute, :changed?
    end

    test "an attribute is changed if it's been assigned a new value" do
      attribute = Attribute.from_database(:foo, 1, Type::Value.new)
      changed = attribute.with_value_from_user(2)

      assert_predicate changed, :changed?
    end

    test "an attribute is not changed if it's assigned the same value" do
      attribute = Attribute.from_database(:foo, 1, Type::Value.new)
      unchanged = attribute.with_value_from_user(1)

      assert_not_predicate unchanged, :changed?
    end

    test "an attribute cannot be mutated if it has not been read,
      and skips expensive calculations" do
      type_which_raises_from_all_methods = Object.new
      attribute = Attribute.from_database(:foo, "bar", type_which_raises_from_all_methods)

      assert_not_predicate attribute, :changed_in_place?
    end

    test "an attribute is changed if it has been mutated" do
      attribute = Attribute.from_database(:foo, "bar", Type::String.new)
      attribute.value << "!"

      assert_predicate attribute, :changed_in_place?
      assert_predicate attribute, :changed?
    end

    test "an attribute can forget its changes" do
      attribute = Attribute.from_database(:foo, "bar", Type::String.new)
      changed = attribute.with_value_from_user("foo")
      forgotten = changed.forgetting_assignment

      assert changed.changed? # sanity check
      assert_not_predicate forgotten, :changed?
    end

    test "with_value_from_user validates the value" do
      type = Type::Value.new
      type.define_singleton_method(:assert_valid_value) do |value|
        if value == 1
          raise ArgumentError
        end
      end

      attribute = Attribute.from_database(:foo, 1, type)
      assert_equal 1, attribute.value
      assert_equal 2, attribute.with_value_from_user(2).value
      assert_raises ArgumentError do
        attribute.with_value_from_user(1)
      end
    end

    test "with_type preserves mutations" do
      attribute = Attribute.from_database(:foo, +"", Type::Value.new)
      attribute.value << "1"

      assert_equal 1, attribute.with_type(Type::Integer.new).value
    end
  end
end
