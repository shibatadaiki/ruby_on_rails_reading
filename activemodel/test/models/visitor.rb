# frozen_string_literal: true

# passwordを持ったテストユーザー？のclass Visitorを定義
class Visitor
  extend ActiveModel::Callbacks
  include ActiveModel::SecurePassword

  define_model_callbacks :create

  has_secure_password(validations: false)

  attr_accessor :password_digest
  attr_reader :password_confirmation
end
