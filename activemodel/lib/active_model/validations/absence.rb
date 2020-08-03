

# frozen_string_literal: true

module ActiveModel
  module Validations
    # == \Active \Model Absence Validator
    # 具象：不在バリデーターの処理を追加
    class AbsenceValidator < EachValidator #:nodoc:
      def validate_each(record, attr_name, value)
        # present検証を追加 -> 「if value.present?」であれば「record.errors」が発生、
        # と言うのがRailsModelのバリデーションの仕組み
        record.errors.add(attr_name, :present, **options) if value.present?
      end
    end

    module HelperMethods
      #＃指定された属性が空白であることを検証します（
      #＃Object＃present？）。 保存時にデフォルトで発生します。
      #
      #   class Person < ActiveRecord::Base
      #     validates_absence_of :first_name
      #   end
      #
      #＃first_name属性はオブジェクト内にあり、空白である必要があります。
      #＃
      #＃設定オプション：
      #＃* <tt>：message </ tt>-カスタムエラーメッセージ（デフォルトは「空白である必要があります」）。
      # ＃
      # ＃すべてのバリデーターがサポートするデフォルトのオプションのリストもあります：
      # ＃+：if +、+：unless +、+：on +、+：allow_nil +、+：allow_blank +、+：strict +。
      # ＃詳細は、<tt> ActiveModel :: Validations＃validates </ tt>を参照してください
      #
      # AbsenceValidator => validate: に付与されたpresentバリデーション処理付与
      def validates_absence_of(*attr_names)
        validates_with AbsenceValidator, _merge_attributes(attr_names)
      end
    end
  end
end
