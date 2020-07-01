# done

# frozen_string_literal: true

#--
#＃ほとんどのオブジェクトは複製可能ですが、すべてではありません。 たとえば、メソッドを重複させることはできません。
#＃
#＃method（：puts）.dup＃=> TypeError：アロケータがメソッドに対して未定義
#＃
#＃クラスは+ dup + / + clone +を削除することでインスタンスが重複していないことを通知する場合があります
#＃またはそれらから例外を発生させます。 したがって、通常は任意のオブジェクトを複製するには
#＃楽観的なアプローチを使用し、例外をキャッチする準備ができている、と言う：
#＃
#＃arbitrary_object.dupレスキューオブジェクト
#＃
#＃Railsは、オブジェクトがそれほど恣意的ではないいくつかの重要な場所にオブジェクトを複製します。
#＃その救助は非常に高価であり（述語より40倍遅い）、そしてそれは
#＃は頻繁にトリガーされます。
#＃
#＃だからこそ、以下のケースをハードコーディングし、重複をチェックしていますか？ の代わりに
#＃レスキューイディオムを使用します。
#++

# それぞれが複製できるかをチェックするメソッドをモンキーパッチ

class Object
  #＃このオブジェクトを安全に複製できますか？
  #＃
  #＃メソッドオブジェクトの場合はfalse。
  #＃それ以外の場合はtrue。
  def duplicable?
    true
  end
end

class Method
  #＃メソッドは複製できません：
  #＃
  #＃method（：puts）.duplicable？ ＃=> false
  #＃method（：puts）.dup＃=> TypeError：アロケータがメソッドに対して未定義
  def duplicable?
    false
  end
end

class UnboundMethod
  #＃バインドされていないメソッドは複製できません：
  #＃
  #＃method（：puts）.unbind.duplicable？ ＃=> false
  #＃method（：puts）.unbind.dup＃=> TypeError：UnboundMethodのアロケーターが未定義
  def duplicable?
    false
  end
end
