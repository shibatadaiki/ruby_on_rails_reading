# frozen_string_literal: true

# testで使う用のEmailValidatorクラスを定義し、そのメソッドでメールアドレスのバリデーションエラーを発生させる
class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i.match?(value)
      record.errors.add(attribute, message: options[:message] || "is not an email")
    end
  end
end
