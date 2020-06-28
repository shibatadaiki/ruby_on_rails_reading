# frozen_string_literal: true

# 各種型タイプ

# ヘルパー的処理
require "active_model/type/helpers"
require "active_model/type/value"

# 各種オーバーライド
require "active_model/type/big_integer"
require "active_model/type/binary"
require "active_model/type/boolean"
require "active_model/type/date"
require "active_model/type/date_time"
require "active_model/type/decimal"
require "active_model/type/float"
require "active_model/type/immutable_string"
require "active_model/type/integer"
require "active_model/type/string"
require "active_model/type/time"

require "active_model/type/registry"

module ActiveModel
  module Type
    @registry = Registry.new

    class << self
      attr_accessor :registry # :nodoc:

      # レジストリに新しいタイプを追加し、ActiveModel :: Type＃lookupを介して取得できるようにします。
      def register(type_name, klass = nil, **options, &block)
        registry.register(type_name, klass, **options, &block)
      end

      def lookup(*args, **kwargs) # :nodoc:
        registry.lookup(*args, **kwargs)
      end

      def default_value # :nodoc:
        @default_value ||= Value.new
      end
    end

    # 各種属性に付与する型クラスを登録する
    # 型登録がされた属性が初期化されるとcastメソッドが起動し、値に登録された型cast処理をかける
    # cast例
    # https://qiita.com/natsuokawai/items/5ac1a9704805ff17b3f2
    #
    # [3] pry(main)> c.checked
    #  => false
    #[4] pry(main)> c.checked = 1
    #  => 1
    #[5] pry(main)> c.checked
    #  => true (数字がT/Fにキャストされている)
    #[6] pry(main)> c.checked = "off"
    #  => "off"
    #[7] pry(main)> c.checked
    #  => false (文字列が特殊な加工を経てT/Fにキャストされている)
    register(:big_integer, Type::BigInteger)
    register(:binary, Type::Binary)
    register(:boolean, Type::Boolean)
    register(:date, Type::Date)
    register(:datetime, Type::DateTime)
    register(:decimal, Type::Decimal)
    register(:float, Type::Float)
    register(:immutable_string, Type::ImmutableString)
    register(:integer, Type::Integer)
    register(:string, Type::String)
    register(:time, Type::Time)
  end
end
