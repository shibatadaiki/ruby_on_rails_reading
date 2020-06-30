# frozen_string_literal: true

# ヘリコプターとは。。。
# Conversion機能のテストで用いるクラス。モデルの属性に?などを付けてT/Fを返すような処理のテストなのかな。。たぶん。
class Helicopter
  include ActiveModel::Conversion
end

class Helicopter::Comanche
  include ActiveModel::Conversion
end
