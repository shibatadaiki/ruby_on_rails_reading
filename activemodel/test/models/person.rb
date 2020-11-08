# done

# frozen_string_literal: true

# 翻訳機能のテストのために用いられるクラスのよう
class Person
  include ActiveModel::Validations
  extend  ActiveModel::Translation

  attr_accessor :title, :karma, :salary, :gender

  def condition_is_true
    true
  end

  def condition_is_false
    false
  end
end

class Person::Gender
  extend ActiveModel::Translation
end

class Child < Person
end
