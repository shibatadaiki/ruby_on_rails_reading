# frozen_string_literal: true

module ActiveModel
  # :stopdoc:
  module Type
    class Registry
      def initialize
        @registrations = []
      end

      # registerメソッドを用いることで型の登録ができる
      # https://wat-aro.hatenablog.com/entry/2018/08/07/203114
      def register(type_name, klass = nil, **options, &block)
        block ||= proc { |_, *args| klass.new(*args) }
        # キーワード引数を Hash の形式で渡した場合に warning が出るのでその対策らしい？
        # https://tmtms.hatenablog.com/entry/201912/ruby27-module
        block.ruby2_keywords if block.respond_to?(:ruby2_keywords)
        # 初期読み込みの際にregistrations配列に使用する型をぼんぼん登録していくらしい
        registrations << registration_klass.new(type_name, block, **options)
      end

      # 検索？
      def lookup(symbol, *args, **kwargs)
        registration = find_registration(symbol, *args, **kwargs)

        if registration
          registration.call(self, symbol, *args, **kwargs)
        else
          raise ArgumentError, "Unknown type #{symbol.inspect}"
        end
      end

      private
        attr_reader :registrations

        def registration_klass
          Registration
        end

        def find_registration(symbol, *args, **kwargs)
          registrations.find { |r| r.matches?(symbol, *args, **kwargs) }
        end
    end

    class Registration
      # Options must be taken because of https://bugs.ruby-lang.org/issues/10856
      def initialize(name, block, **)
        @name = name
        @block = block
      end

      def call(_registry, *args, **kwargs)
        # ここのcallで[Object].newする
        if kwargs.any? # https://bugs.ruby-lang.org/issues/10856
          block.call(*args, **kwargs)
        else
          block.call(*args)
        end
      end

      def matches?(type_name, *args, **kwargs)
        type_name == name
      end

      private
        attr_reader :name, :block
    end
  end
  # :startdoc:
end
