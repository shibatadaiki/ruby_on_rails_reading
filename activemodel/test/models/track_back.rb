# done

# frozen_string_literal: true

# modelの命名規約的な処理を作るモジュールを取り込んで、model命名規約の処理をテストしているぽい
# Postという名前も命名処理のためのクラスぽい気もする
class Post
  class TrackBack
    def to_model
      NamedTrackBack.new
    end
  end

  class NamedTrackBack
    extend ActiveModel::Naming
  end
end
