# frozen_string_literal: true

require "date"
require "active_support/core_ext/object/acts_like"

class DateTime
  # ~/activesupport/lib/active_support/core_ext/object/acts_like.rb の処理に使う
  # Duck-types as a Date-like class. See Object#acts_like?.
  # 日付のようなクラスとしてのアヒル型。 Object＃acts_like？を参照してください。
  def acts_like_date?
    true
  end

  # ~/activesupport/lib/active_support/core_ext/object/acts_like.rb の処理に使う
  # Duck-types as a Time-like class. See Object#acts_like?.
  # Timeのようなクラスとしてのアヒル型。 Object＃acts_like？を参照してください。
  def acts_like_time?
    true
  end
end
