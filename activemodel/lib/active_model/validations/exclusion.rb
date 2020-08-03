# done

# frozen_string_literal: true

require "active_model/validations/clusivity"

module ActiveModel
  module Validations
    class ExclusionValidator < EachValidator # :nodoc:

      # validateに含まれる範囲系の処理。rangeで値の範囲の判定をするClusivityを含んで、in/withinのバリデーション処理を追加する
      include Clusivity

      def validate_each(record, attribute, value)
        # 含まれていればrecord.errors
        if include?(record, value)
          record.errors.add(attribute, :exclusion, **options.except(:in, :within).merge!(value: value))
        end
      end
    end

    module HelperMethods
      #＃指定された属性の値が
      #＃特定の列挙可能なオブジェクト。      #
      #
      #   class Person < ActiveRecord::Base
      #     validates_exclusion_of :username, in: %w( admin superuser ), message: "You don't belong here"
      #     validates_exclusion_of :age, in: 30..60, message: 'This site is only for under 30 and over 60'
      #     validates_exclusion_of :format, in: %w( mov avi ), message: "extension %{value} is not allowed"
      #     validates_exclusion_of :password, in: ->(person) { [person.username, person.first_name] },
      #                            message: 'should not be the same as your username or first name'
      #     validates_exclusion_of :karma, in: :reserved_karmas
      #   end
      #
      #＃設定オプション：
      #＃* <tt>：in </ tt>-値が許可されないアイテムの列挙可能なオブジェクト
      # ＃   の一部。 これは、proc、lambda、またはシンボルとして提供され、
      # ＃列挙可能。 列挙可能なものが数値、時間、または日時の範囲である場合、テスト
      # ＃は<tt> Range＃cover？</ tt>で実行され、それ以外の場合は<tt> include？</ tt>で実行されます。 いつ
      # ＃procまたはlambdaを使用して、検証中のインスタンスが引数として渡されます。
      # ＃* <tt>：within </ tt>-<tt>：in </ tt>の同義語（またはエイリアス）
      # ＃<tt> Range＃cover？</ tt>、それ以外の場合は<tt> include？</ tt>。
      # ＃* <tt>：message </ tt>-カスタムエラーメッセージを指定します（デフォルトは「is
      #＃予約済み」）。
      #＃
      #＃すべてのバリデーターがサポートするデフォルトのオプションのリストもあります：
      #＃+：if +、+：unless +、+：on +、+：allow_nil +、+：allow_blank +、+：strict +。
      #＃詳細は、<tt> ActiveModel :: Validations＃validates </ tt>を参照してください
      def validates_exclusion_of(*attr_names)
        validates_with ExclusionValidator, _merge_attributes(attr_names)
      end
    end
  end
end
