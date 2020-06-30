# frozen_string_literal: true

class Object
  # A duck-type assistant method. For example, Active Support extends Date
  # to define an <tt>acts_like_date?</tt> method, and extends Time to define
  # <tt>acts_like_time?</tt>. As a result, we can do <tt>x.acts_like?(:time)</tt> and
  # <tt>x.acts_like?(:date)</tt> to do duck-type-safe comparisons, since classes that
  # we want to act like Time simply need to define an <tt>acts_like_time?</tt> method.
  #  ＃アヒル型アシスト＃アヒル型アシスタント方式。 たとえば、アクティブサポートは日付を延長します
  #  ＃<tt> acts_like_date？</ tt>メソッドを定義し、定義する時間を拡張する
  #   ＃<tt> acts_like_time？</ tt>。 その結果、<tt> x.acts_like？（：time）</ tt>および
  #   ＃<tt> x.acts_like？（：date）</ tt>は、アヒルのタイプセーフな比較を行います。
  #  ＃時間のように振る舞うには、単に<tt> acts_like_time？</ tt>メソッドを定義する必要があります。

  # acts_like?で、引数とレシーバの型インスタンスが合致していることを確認できる
  # 「~のように振舞うか？」
  def acts_like?(duck)
    case duck
    when :time
      respond_to? :acts_like_time?
    when :date
      respond_to? :acts_like_date?
    when :string
      respond_to? :acts_like_string?
    else
      respond_to? :"acts_like_#{duck}?"
    end
  end
end
