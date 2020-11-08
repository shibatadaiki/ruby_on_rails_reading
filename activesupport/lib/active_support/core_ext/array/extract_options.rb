# done

# frozen_string_literal: true

class Hash
  # By default, only instances of Hash itself are extractable.
  # Subclasses of Hash may implement this method and return
  # true to declare themselves as extractable. If a Hash
  # is extractable, Array#extract_options! pops it from
  # the Array when it is the last element of the Array.

  #   ＃デフォルトでは、ハッシュ自体のインスタンスのみが抽出可能です。
  #  ＃Hashのサブクラスはこのメソッドを実装して返すことができます
  #  ＃自分自身を抽出可能として宣言する場合はtrue。 ハッシュの場合
  #  ＃は抽出可能、Array＃extract_options！ からそれをポップ
  #  ＃配列の最後の要素である場合は、配列。
  def extractable_options?
    instance_of?(Hash)
  end
end

class Array
  # Extracts options from a set of arguments. Removes and returns the last
  # element in the array if it's a hash, otherwise returns a blank hash.
  #
  #   def options(*args)
  #     args.extract_options!
  #   end
  #
  #   options(1, 2)        # => {}
  #   options(1, 2, a: :b) # => {:a=>:b}

  # ＃引数のセットからオプションを抽出します。 最後を削除して返します
  #   ＃ハッシュの場合は配列内の要素。
  def extract_options!
    if last.is_a?(Hash) && last.extractable_options?
      # 配列の最後の要素がoption値の入ったハッシュであるというルールになっている？
      pop
    else
      {}
    end
  end
end
