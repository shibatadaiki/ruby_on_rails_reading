# done

# frozen_string_literal: true

require "active_model/validations/clusivity"

module ActiveModel
  module Validations
    class InclusionValidator < EachValidator # :nodoc:
      include Clusivity

      def validate_each(record, attribute, value)
        # include? -> /lib/active_model/validations/clusivity.rbのメソッド
        # :in, :withinを除くvalueのバリデーションをかける
        unless include?(record, value)
          record.errors.add(attribute, :inclusion, **options.except(:in, :within).merge!(value: value))
        end
      end
    end

    module HelperMethods
      # ＃指定された属性の値が特定の列挙可能なオブジェクト。
      #
      #   class Person < ActiveRecord::Base
      #     validates_inclusion_of :role, in: %w( admin contributor )
      #     validates_inclusion_of :age, in: 0..99
      #     validates_inclusion_of :format, in: %w( jpg gif png ), message: "extension %{value} is not included in the list"
      #     validates_inclusion_of :states, in: ->(person) { STATES[person.country] }
      #     validates_inclusion_of :karma, in: :available_karmas
      #   end
      #
      # ＃設定オプション：
      #       ＃* <tt>：in </ tt>-利用可能なアイテムの列挙可能なオブジェクト。 これは
      #       ＃列挙型を返すプロシージャ、ラムダ、またはシンボルとして提供されます。 もし
      #       ＃enumerableは、テストが実行される数値、時間、または日時の範囲です
      #       ＃<tt> Range＃cover？</ tt>、それ以外の場合は<tt> include？</ tt>。 使用する場合
      #       ＃検証中のインスタンスのプロシージャまたはラムダが引数として渡されます。
      #       ＃* <tt>：within </ tt>-<tt>：in </ tt>の同義語（またはエイリアス）
      #       ＃* <tt>：message </ tt>-カスタムエラーメッセージを指定します（デフォルトは「is
      #       ＃リストに含まれていない」）。
      #       ＃
      #       ＃すべてのバリデーターがサポートするデフォルトのオプションのリストもあります：
      #       ＃+：if +、+：unless +、+：on +、+：allow_nil +、+：allow_blank +、+：strict +。
      #       ＃詳細は、<tt> ActiveModel :: Validations＃validates </ tt>を参照してください
      #
      # optionsに options[:attributes] = attr_names を追加する
      def validates_inclusion_of(*attr_names)
        validates_with InclusionValidator, _merge_attributes(attr_names)
      end
    end
  end
end
