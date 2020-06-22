# frozen_string_literal: true

# バージョン切り替わるたびにここを書き換えている感じ・・・？
# だとしたらなかなか愚直なような
module ActiveModel
  # Returns the version of the currently loaded \Active \Model as a <tt>Gem::Version</tt>
  def self.gem_version
    Gem::Version.new VERSION::STRING
  end

  module VERSION
    MAJOR = 6
    MINOR = 1
    TINY  = 0
    PRE   = "alpha"

    STRING = [MAJOR, MINOR, TINY, PRE].compact.join(".")
  end
end
