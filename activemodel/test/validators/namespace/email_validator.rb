# done

# frozen_string_literal: true

# test使用用のクラスを作成？
require "validators/email_validator"

module Namespace
  class EmailValidator < ::EmailValidator
  end
end
