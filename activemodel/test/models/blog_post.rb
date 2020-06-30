# frozen_string_literal: true

module Blog
  # 「Post」の任意モデル命名として「Blog」という名前を用いてその箇所の命名規約をテストしている？
  def self.use_relative_model_naming?
    true
  end

  class Post
    extend ActiveModel::Naming
  end
end
