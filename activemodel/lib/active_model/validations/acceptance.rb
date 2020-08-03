# done

# frozen_string_literal: true

module ActiveModel
  module Validations
    class AcceptanceValidator < EachValidator # :nodoc:
      # allow_nilとpresent(1/true)のおpションを受け入れてから他のモジュールを遅延読み込みしている？
      def initialize(options)
        super({ allow_nil: true, accept: ["1", true] }.merge!(options))
        setup!(options[:class])
      end

      def validate_each(record, attribute, value)
        unless acceptable_option?(value)
          record.errors.add(attribute, :accepted, **options.except(:accept, :allow_nil))
        end
      end

      private
        def setup!(klass)
          # 属性の遅延定義
          define_attributes = LazilyDefineAttributes.new(attributes)
          klass.include(define_attributes) unless klass.included_modules.include?(define_attributes)
        end

        def acceptable_option?(value)
          Array(options[:accept]).include?(value)
        end

        class LazilyDefineAttributes < Module
          def initialize(attributes)
            @attributes = attributes.map(&:to_s)
          end

          def included(klass)
            # https://docs.ruby-lang.org/ja/1.9.3/class/Mutex.html
            # Mutex(Mutal Exclusion = 相互排他ロック)は共有データを並行アクセスから保護する ためにあります。
            @lock = Mutex.new
            mod = self

            define_method(:respond_to_missing?) do |method_name, include_private = false|
              mod.define_on(klass)
              super(method_name, include_private) || mod.matches?(method_name)
            end

            # attributesがマッチしたら（ここので定義されている値と一致したら）method_missingをオーバーライドして
            # なかったことにし、もう一度そのメソッドを実行する
            # なかったら、superで普通にmethod_missingでエラーを起こす
            define_method(:method_missing) do |method_name, *args, &block|
              mod.define_on(klass)
              if mod.matches?(method_name)
                send(method_name, *args, &block)
              else
                super(method_name, *args, &block)
              end
            end
          end

          def matches?(method_name)
            attr_name = method_name.to_s.chomp("=")
            attributes.any? { |name| name == attr_name }
          end

          # 遅延されてきた属性をattr_reader、attr_writerで再定義している？
          def define_on(klass)
            # https://docs.ruby-lang.org/ja/latest/method/Thread=3a=3aMutex/i/synchronize.html
            # synchronize { ... } -> object[permalink][rdoc]
            # mutex をロックし、ブロックを実行します。実行後に必ず mutex のロックを解放します。
            #
            # 排他的に属性定義を実行する
            @lock&.synchronize do
              return unless @lock

              attr_readers = attributes.reject { |name| klass.attribute_method?(name) }
              attr_writers = attributes.reject { |name| klass.attribute_method?("#{name}=") }

              attr_reader(*attr_readers)
              attr_writer(*attr_writers)

              remove_method :respond_to_missing?
              remove_method :method_missing

              @lock = nil
            end
          end

          def ==(other)
            self.class == other.class && attributes == other.attributes
          end

          protected
            attr_reader :attributes
        end
    end

    module HelperMethods
      #属性の遅延定義＃の承認を検証するパターンをカプセル化します。
      #＃利用規約のチェックボックス（または同様の契約）。      #
      #
      #   class Person < ActiveRecord::Base
      #     validates_acceptance_of :terms_of_service
      #     validates_acceptance_of :eula, message: 'must be abided'
      #   end
      #
      #＃データベース列が存在しない場合、+ terms_of_service +属性
      #＃完全に仮想です。 このチェックは、+ terms_of_service +
      #            ＃は+ nil +ではなく、デフォルトでは保存時です。
      #＃
      #＃設定オプション：
      #＃* <tt>：message </ tt>-カスタムエラーメッセージ（デフォルトは「
      # ＃承認されました」）。
      # ＃* <tt>：accept </ tt>-受け入れられたと見なされる値を指定します。
      #＃可能な値の配列も受け入れます。 デフォルト値は
      #＃配列["1"、true]は、HTMLとの関連付けを容易にします
      #＃チェックボックス。 検証する場合は、これを+ true +に設定するか、含める必要があります。
      #＃属性は「1」から+ true +への型キャストであるため、データベース列
      #＃検証前。
      #＃
      #＃すべてのバリデーターがサポートするデフォルトのオプションのリストもあります：
      #＃+：if +、+：unless +、+：on +、+：allow_nil +、+：allow_blank +、+：strict +。
      #＃詳細は、<tt> ActiveModel :: Validations＃validates </ tt>を参照してください。
      #
      # https://qiita.com/rkonno/items/b6c77a2e994c6e0e86df
      # チェックボックスのバリデーションを追加できる
      def validates_acceptance_of(*attr_names)
        validates_with AcceptanceValidator, _merge_attributes(attr_names)
      end
    end
  end
end
