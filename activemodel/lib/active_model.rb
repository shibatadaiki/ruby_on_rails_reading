# frozen_string_literal: true

#＃-
#  ＃Copyright（c）2004-2020 David Heinemeier Hansson
#＃
#＃これにより、取得するすべての人に無料で許可が与えられます
#＃このソフトウェアと関連ドキュメントファイルのコピー（
#＃「ソフトウェア」）、以下を含む制限なしでソフトウェアを扱う
#＃制限なしで、使用、コピー、変更、マージ、公開、
#＃ソフトウェアのコピーを配布、サブライセンス、および/または販売し、
#＃本ソフトウェアの提供を受けた者がそうすることを許可する
#＃次の条件：
#＃
#＃上記の著作権表示とこの許可通知は、
#＃ソフトウェアのすべてのコピーまたは実質的な部分に含まれます。
#＃
#＃本ソフトウェアは「現状有姿」で提供され、いかなる種類の保証もありません。
#＃明示または黙示を含みますが、これに限定されません。
#＃商品性、特定の目的への適合性、および
#＃非侵害。いかなる場合も、著者または著作権者は
#＃訴訟において、請求、損害またはその他の責任について責任を負う
#契約、不法行為、またはその他の理由で発生した、関連していない、または関連している契約の数
#＃本ソフトウェアまたは本ソフトウェアの使用またはその他の取引。
#＃++

# アクティブモデルは、モデルクラスで使用するための既知のインターフェイスのセットを提供します。
# たとえば、アクションパックヘルパーが非アクティブレコードモデルとやり取りできるようにします。
# アクティブモデルは、Railsフレームワークの外部で使用するカスタムORMの構築にも役立ちます。
# （要するにビジネスロジック処理で使うような機能。プレーンなrubyオブジェクトがActionPackとやりとりできるようになる機能が使えるようになる）

# このファイルで ~/activemodel/lib/active_model/xxx.rb のファイルを読み込む処理をしている
# つまり始点？のようなファイル

# active_supportの便利メソッドを使用している
require "active_support"
require "active_support/rails"
# version管理は別ファイル（ディレクトリ）で管理している
require "active_model/version"

module ActiveModel
  # ActiveSupport::Autoloadモジュールのインスタンスメソッドが、ActiveModelの特異（クラス）メソッドとして追加される。
  extend ActiveSupport::Autoload

  # https://api.rubyonrails.org/classes/ActiveSupport/Autoload.html
  # このモジュールを使用すると、Railsの規則に基づいてオートロードを定義でき（つまり、ファイル名に基づいて自動的に推測されるパスを定義する必要がありません）
  # 積極的にロードする必要のある一連の定数を定義できます。
  # https://www.slideshare.net/TomohikoHimura/rails-25983089
  # autoload -> あるクラスが必要になったときに初めてファイルを読み込みする。
  # つまり「ActiveModel」をincludeしておけば、ActiveModelがいつでも必要なタイミング（そのモジュールのメソッドが呼び出されたタイミング？）
  # で、モジュールをロードしてメソッドを使えるようにしてくれる。。みたいな感じ。たぶん。
  # 第一引数 -> あるクラスの名前 第二引数 -> 読み込みするファイル（ただし第二引数は規約から推測可能。省略可能）

  # ~/activemodel/lib/active_model/attribute.rb
  autoload :Attribute
  autoload :Attributes
  autoload :AttributeAssignment
  autoload :AttributeMethods
  autoload :BlockValidator, "active_model/validator"
  autoload :Callbacks
  autoload :Conversion
  autoload :Dirty
  autoload :EachValidator, "active_model/validator"
  autoload :ForbiddenAttributesProtection
  autoload :Lint
  autoload :Model
  autoload :Name, "active_model/naming"
  autoload :Naming
  autoload :SecurePassword
  autoload :Serialization
  autoload :Translation
  autoload :Type
  autoload :Validations
  autoload :Validator

  # eager_autoloadでautoloadを囲むと、eager_load!でファイルをまとめ読みできる（たぶん）
  #   ActiveModel::Serializers.eager_load! ->
  #     def eager_load!
  #      @_autoloads.each_value { |file| require file }
  #    end
  eager_autoload do
    autoload :Errors
    autoload :Error
    autoload :RangeError, "active_model/errors"
    autoload :StrictValidationFailed, "active_model/errors"
    autoload :UnknownAttributeError, "active_model/errors"
  end

  module Serializers
    # ActiveSupport::Autoloadモジュールのインスタンスメソッドが、ActiveModelの特異（クラス）メソッドとして追加される。
    extend ActiveSupport::Autoload

    # JSONパッケージを読み込む時はmodule Serializersで別枠として管理している。
    # ~/activemodel/lib/active_model/serializers/json.rb を読み込んでいる。
    eager_autoload do
      autoload :JSON
    end
  end

  # eager_autoloadのまとめ読みのための処理を記述
  def self.eager_load!
    super
    ActiveModel::Serializers.eager_load!
  end
end

# ~/activemodel/lib/active_model/locale/en.yml をロード.
# model処理のバリデーションメッセージ設定
#
# on_loadはlazy_load_hooksという遅延処理に関連するモジュールのメソッド
# 対象スコープとなるモジュールが読み込まれた後でblockに渡した処理を遅延実行できる
# https://qiita.com/iwsksky/items/cfca74f08e10fe3e2eb8
ActiveSupport.on_load(:i18n) do
  I18n.load_path << File.expand_path("active_model/locale/en.yml", __dir__)
end
