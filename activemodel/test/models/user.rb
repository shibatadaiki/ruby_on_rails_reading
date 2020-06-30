# frozen_string_literal: true

# passwordを持ったテストユーザー？のclass Userを定義
class User
  extend ActiveModel::Callbacks
  include ActiveModel::SecurePassword

  define_model_callbacks :create

  has_secure_password
  has_secure_password :recovery_password, validations: false

  attr_accessor :password_digest, :recovery_password_digest
  attr_accessor :password_called

  # passwordが呼ばれた回数を計算している（x回間違えたらロック的な機能を試すため？？）
  # visitorは制限ないけどuser歯あるみたいな感じで差異のテストをするのだろうか
  def password=(unencrypted_password)
    self.password_called ||= 0
    self.password_called += 1
    super
  end
end
