# done

# frozen_string_literal: true

module ActiveModel
  module Validations
    #＃==アクティブな\ Model \ Validation \ Callbacks
    #＃
    #＃すべてのクラスが+ before_validation +および
    #＃+ after_validation +コールバック。
    #＃
    #＃最初に、現在のクラスのActiveModel :: Validations :: Callbacksを含めます    # creating:
    #
    #   class MyModel
    #     include ActiveModel::Validations::Callbacks
    #
    #     before_validation :do_stuff_before_validation
    #     after_validation  :do_stuff_after_validation
    #   end
    #
    # ＃+ before_validation +がスローした場合、他の<tt> before _ * </ tt>コールバックと同様
    # +:abort+ then <tt>valid?</tt> will not be called.
    module Callbacks
      extend ActiveSupport::Concern

      included do
        include ActiveSupport::Callbacks
        define_callbacks :validation,
                         skip_after_callbacks_if_terminated: true,
                         scope: [:kind, :name]
      end

      module ClassMethods
        # 検証の直前に呼び出されるコールバックを定義します。
        #
        #   class Person
        #     include ActiveModel::Validations
        #     include ActiveModel::Validations::Callbacks
        #
        #     attr_accessor :name
        #
        #     validates_length_of :name, maximum: 6
        #
        #     before_validation :remove_whitespaces
        #
        #     private
        #
        #     def remove_whitespaces
        #       name.strip!
        #     end
        #   end
        #
        #   person = Person.new
        #   person.name = '  bob  '
        #   person.valid? # => true
        #   person.name   # => "bob"
        #
        # モデルに定義されたバリデーションを実際の処理に起こしてコールバックに渡す
        def before_validation(*args, &block)
          options = args.extract_options!

          if options.key?(:on)
            options = options.dup
            options[:on] = Array(options[:on])
            options[:if] = Array(options[:if])
            options[:if].unshift ->(o) {
              !(options[:on] & Array(o.validation_context)).empty?
            }
          end

          set_callback(:validation, :before, *args, options, &block)
        end

        # 検証直後に呼び出されるコールバックを定義します。
        #
        #   class Person
        #     include ActiveModel::Validations
        #     include ActiveModel::Validations::Callbacks
        #
        #     attr_accessor :name, :status
        #
        #     validates_presence_of :name
        #
        #     after_validation :set_status
        #
        #     private
        #
        #     def set_status
        #       self.status = errors.empty?
        #     end
        #   end
        #
        #   person = Person.new
        #   person.name = ''
        #   person.valid? # => false
        #   person.status # => false
        #   person.name = 'bob'
        #   person.valid? # => true
        #   person.status # => true
        #
        # モデルに定義されたバリデーションを実際の処理に起こしてコールバックに渡す
        def after_validation(*args, &block)
          options = args.extract_options!
          options = options.dup
          options[:prepend] = true

          if options.key?(:on)
            options[:on] = Array(options[:on])
            options[:if] = Array(options[:if])
            options[:if].unshift ->(o) {
              !(options[:on] & Array(o.validation_context)).empty?
            }
          end

          set_callback(:validation, :after, *args, options, &block)
        end
      end

    private
      # 実行検証を上書きしてコールバックを含めます。
      def run_validations!
        _run_validation_callbacks { super }
      end
    end
  end
end
