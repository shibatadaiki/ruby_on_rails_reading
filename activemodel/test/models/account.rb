# done

# frozen_string_literal: true

# 任意使用が禁止されている属性（「id」とか？）を保護するための機能をテストしているぽい
class Account
  include ActiveModel::ForbiddenAttributesProtection

  public :sanitize_for_mass_assignment
end
