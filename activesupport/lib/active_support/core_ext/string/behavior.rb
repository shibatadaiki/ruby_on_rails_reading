# done

# frozen_string_literal: true

class String
  # ~/activesupport/lib/active_support/core_ext/object/acts_like.rb の処理に使う
  # Enables more predictable duck-typing on String-like classes. See <tt>Object#acts_like?</tt>.
  # Stringのようなクラスで、より予測可能なダックタイピングを可能にします。 <tt> Object＃acts_like？</ tt>を参照してください。
  def acts_like_string?
    true
  end
end
