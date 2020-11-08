# done

# frozen_string_literal: true

module ActiveModel
  module Type
    module Helpers # :nodoc: all
      # 可変モジュール。ActiveRecordで使われている。
      module Mutable
        # ActiveRecordの各値にdeserialize処理をかける？
        def cast(value)
          deserialize(serialize(value))
        end

        # +raw_old_value+ will be the `_before_type_cast` version of the
        # value (likely a string). +new_value+ will be the current, type
        # cast value.
        # ＃+ raw_old_value +は、 `_before_type_cast`バージョンの
        #         ＃値（おそらく文字列）。 + new_value +が現在のタイプになります
        #         ＃キャスト値。

        # serializeした値と以前の値を比べて内容が変更されているかどうかを確認する
        def changed_in_place?(raw_old_value, new_value)
          raw_old_value != serialize(new_value)
        end
      end
    end
  end
end
