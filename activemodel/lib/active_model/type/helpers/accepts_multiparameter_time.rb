# frozen_string_literal: true

module ActiveModel
  module Type
    module Helpers # :nodoc: all
      class AcceptsMultiparameterTime < Module
        # マルチパラメータ時間を受け入れるモジュール。Hashだったらvalue_from_multiparameter_assignmentを起動させるためのモジュール
        def initialize(defaults: {})
          define_method(:serialize) do |value|
            # super(cast -> ~/activemodel/lib/active_model/type/value.rb のcastメソッドに飛ぶ
            super(cast(value))
          end

          define_method(:cast) do |value|
            if value.is_a?(Hash)
              # define_method(:value_from_multiparameter_assignment) do ~に飛ぶ
              value_from_multiparameter_assignment(value)
            else
              # super(cast -> ~/activemodel/lib/active_model/type/value.rb のcastメソッドに飛ぶ
              super(value)
            end
          end

          define_method(:assert_valid_value) do |value|
            if value.is_a?(Hash)
              # define_method(:value_from_multiparameter_assignment) do ~に飛ぶ
              value_from_multiparameter_assignment(value)
            else
              # super(cast -> ~/activemodel/lib/active_model/type/value.rb のassert_valid_valueメソッドに飛ぶ
              # （つまりelseの条件文に入ったら何もしない。validationを素通りする）
              super(value)
            end
          end

          # 「一括割り当てによって構築された値かどうか?」
          define_method(:value_constructed_by_mass_assignment?) do |value|
            value.is_a?(Hash)
          end

          # hashオブジェクトだったらこのメソッドを通す
          # ["2019", "11", "1", "20", "45"] => 2019-11-01 20:45:00 UTC
          # のような感じで、Hashのvalueに渡された各値を時間に直すメソッド
          define_method(:value_from_multiparameter_assignment) do |values_hash|
            defaults.each do |k, v|
              values_hash[k] ||= v
            end
            # 年月日がないものはreturnする
            return unless values_hash[1] && values_hash[2] && values_hash[3]
            values = values_hash.sort.map(&:last)
            ::Time.send(default_timezone, *values)
          end
          private :value_from_multiparameter_assignment
        end
      end
    end
  end
end
