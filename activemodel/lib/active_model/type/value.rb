# frozen_string_literal: true

module ActiveModel
  module Type
    class Value
      attr_reader :precision, :scale, :limit

      # オーバーライド元の抽象クラス。Valueクラスのメソッドは基本的に子供のクラスのsuperで使われる

      def initialize(precision: nil, limit: nil, scale: nil)
        @precision = precision
        @scale = scale
        @limit = limit
      end

      def type # :nodoc:
      end

      # Converts a value from database input to the appropriate ruby type. The
      # return value of this method will be returned from
      # ActiveRecord::AttributeMethods::Read#read_attribute. The default
      # implementation just calls Value#cast.
      #
      # +value+ The raw input, as provided from the database.

      # ＃値をデータベース入力から適切なルビ型に変換します。
      # ＃このメソッドの戻り値はActiveRecord :: AttributeMethods :: Read＃read_attribute。
      # ＃デフォルト実装はValue＃castを呼び出すだけです。
      # ＃
      # ＃+ value +データベースから提供される生の入力。
      def deserialize(value)
        cast(value)
      end

      # Type casts a value from user input (e.g. from a setter). This value may
      # be a string from the form builder, or a ruby object passed to a setter.
      # There is currently no way to differentiate between which source it came
      # from.
      #
      # The return value of this method will be returned from
      # ActiveRecord::AttributeMethods::Read#read_attribute. See also:
      # Value#cast_value.
      #
      # +value+ The raw input, as provided to the attribute setter.

      # ＃タイプは、ユーザー入力（たとえば、セッター）から値をキャストします。 この値は
      #       ＃フォームビルダーからの文字列、またはセッターに渡されたルビオブジェクト。
      #       ＃現在、どのソースから来たかを区別する方法はありません
      #       ＃から。
      #       ＃
      #       ＃このメソッドの戻り値は
      #       ＃ActiveRecord :: AttributeMethods :: Read＃read_attribute。 以下も参照してください。
      #       ＃Value＃cast_value。
      #       ＃
      #       ＃+ value +属性セッターに提供される生の入力。
      def cast(value)
        cast_value(value) unless value.nil?
      end

      # Casts a value from the ruby type to a type that the database knows how
      # to understand. The returned value from this method should be a

      # ＃ルビ型からデータベースがどのように知っている型に値をキャストします
      #       ＃理解する。 このメソッドからの戻り値は
      # +String+, +Numeric+, +Date+, +Time+, +Symbol+, +true+, +false+, or
      # +nil+.
      def serialize(value)
        value
      end

      # Type casts a value for schema dumping. This method is private, as we are
      # hoping to remove it entirely.

      # ＃タイプは、スキーマダンプの値をキャストします。 このメソッドは、私たちのようにプライベートです
      #       ＃完全に削除したい。
      def type_cast_for_schema(value) # :nodoc:
        value.inspect
      end

      # These predicates are not documented, as I need to look further into
      # their use, and see if they can be removed entirely.

      # ＃これらの述語は、詳しく調べる必要があるため、文書化されていません
      #       ＃それらを使用し、完全に削除できるかどうかを確認します。
      def binary? # :nodoc:
        false
      end

      # Determines whether a value has changed for dirty checking. +old_value+
      # and +new_value+ will always be type-cast. Types should not need to
      # override this method.

      # ＃ダーティチェックの値が変更されたかどうかを判断します。 + old_value +
      #       ＃および+ new_value +は常に型キャストされます。 タイプはする必要はありません
      #       ＃このメソッドをオーバーライドします。
      def changed?(old_value, new_value, _new_value_before_type_cast)
        old_value != new_value
      end

      # Determines whether the mutable value has been modified since it was
      # read. Returns +false+ by default. If your type returns an object
      # which could be mutated, you should override this method. You will need
      # to either:
      #
      # - pass +new_value+ to Value#serialize and compare it to
      #   +raw_old_value+
      #
      # or
      #
      # - pass +raw_old_value+ to Value#deserialize and compare it to
      #   +new_value+
      #
      # +raw_old_value+ The original value, before being passed to
      # +deserialize+.
      #
      # +new_value+ The current value, after type casting.

      # ＃変更可能な値が変更されたかどうかを決定します
      #       ＃ 読んだ。 デフォルトでは+ false +を返します。 タイプがオブジェクトを返す場合
      #       ＃変更される可能性があるため、このメソッドをオーバーライドする必要があります。 必要になるだろう
      #       ＃次のいずれかに：
      #       ＃
      #       ＃-+ new_value +をValue＃serializeに渡して比較します
      #       ＃+ raw_old_value +
      #       ＃
      #       ＃または
      #       ＃
      #       ＃-+ raw_old_value +をValue＃deserializeに渡して比較します
      #       ＃+ new_value +
      #       ＃
      #       ＃+ raw_old_value +に渡される前の元の値
      #       ＃+ deserialize +。
      #       ＃
      #       ＃+ new_value +型キャスト後の現在の値。
      def changed_in_place?(raw_old_value, new_value)
        false
      end

      # 一括割り当てによって構築された値？
      def value_constructed_by_mass_assignment?(_value) # :nodoc:
        false
      end

      def force_equality?(_value) # :nodoc:
        false
      end

      def map(value) # :nodoc:
        yield value
      end

      def ==(other)
        self.class == other.class &&
          precision == other.precision &&
          scale == other.scale &&
          limit == other.limit
      end
      alias eql? ==

      def hash
        [self.class, precision, scale, limit].hash
      end

      def assert_valid_value(_)
      end

      private
        # Convenience method for types which do not need separate type casting
        # behavior for user and database inputs. Called by Value#cast for
        # values except +nil+.

        # ＃個別の型キャストを必要としない型の簡易メソッド
        # ＃ユーザーおよびデータベース入力の動作。 Value＃castによって呼び出されます
        # ＃+ nil +以外の値。
        def cast_value(value) # :doc:
          value
        end
    end
  end
end
