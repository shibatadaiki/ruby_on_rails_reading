# done

# frozen_string_literal: true

module ActiveModel
  module Validations
    module HelperMethods # :nodoc:
      private
        def _merge_attributes(attr_names)
          # optionに検証用の属性名を追加している
          options = attr_names.extract_options!.symbolize_keys
          attr_names.flatten!
          options[:attributes] = attr_names
          options
        end
    end
  end
end
