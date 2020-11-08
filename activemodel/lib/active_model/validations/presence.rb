# done

# frozen_string_literal: true

module ActiveModel
  module Validations
    # 値の存在チェック -> if value.blank?
    class PresenceValidator < EachValidator # :nodoc:
      def validate_each(record, attr_name, value)
        record.errors.add(attr_name, :blank, **options) if value.blank?
      end
    end

    module HelperMethods
      # ＃指定された属性が空白ではないことを検証します（
      #       ＃Object＃blank？）。 保存時にデフォルトで発生します。 #
      #
      #   class Person < ActiveRecord::Base
      #     validates_presence_of :first_name
      #   end
      #
      # ＃first_name属性はオブジェクト内にある必要があり、空白にすることはできません。
      #       ＃
      #       ＃ブール値フィールドの存在を検証したい場合（実際の
      #       ＃値は+ true +および+ false +）であり、使用する必要があります
      #       ＃<tt> validates_inclusion_of：field_name、in：[true、false] </ tt>。
      #       ＃
      #       ＃これはObject＃blankの方法によるものですか？ ブール値を処理します。
      #       ＃<tt> false.blank？ ＃=> true </ tt>。
      #       ＃
      #       ＃設定オプション：
      #       ＃* <tt>：message </ tt>-カスタムエラーメッセージ（デフォルトは「空白にすることはできません」）。
      #       ＃
      #       ＃すべてのバリデーターがサポートするデフォルトのオプションのリストもあります：
      #       ＃+：if +、+：unless +、+：on +、+：allow_nil +、+：allow_blank +、+：strict +。
      #       ＃詳細は、<tt> ActiveModel :: Validations＃validates </ tt>を参照してください
      def validates_presence_of(*attr_names)
        validates_with PresenceValidator, _merge_attributes(attr_names)
      end
    end
  end
end
