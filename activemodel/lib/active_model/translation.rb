# done

# frozen_string_literal: true

module ActiveModel
  # == Active \Model \Translation
  #
  # Provides integration between your object and the Rails internationalization
  # (i18n) framework.
  #
  # A minimal implementation could be:
  #
  #   class TranslatedPerson
  #     extend ActiveModel::Translation
  #   end
  #
  #   TranslatedPerson.human_attribute_name('my_attribute')
  #   # => "My attribute"
  #
  # This also provides the required class methods for hooking into the
  # Rails internationalization API, including being able to define a
  # class based +i18n_scope+ and +lookup_ancestors+ to find translations in
  # parent classes.

  # ＃==アクティブな\ Model \ Translation
  #   ＃
  #   ＃オブジェクトとRailsの国際化間の統合を提供します
  #   ＃（i18n）フレームワーク。
  #   ＃
  #   ＃最小限の実装は次のとおりです。
  #   ＃
  #   ＃クラスTranslatedPerson
  #   ＃ActiveModel :: Translationを拡張
  #   ＃   終わり
  #   ＃
  #   ＃TranslatedPerson.human_attribute_name（ 'my_attribute'）
  #   ＃＃=>「私の属性」
  #   ＃
  #   ＃これはまた、にフックするために必要なクラスメソッドを提供します
  #   ＃Railsの国際化API（定義できることを含む）
  #   ＃クラスベース+ i18n_scope +および+ lookup_ancestors +で翻訳を検索
  #   ＃親クラス。

  # 翻訳モジュール
  module Translation
    include ActiveModel::Naming

    # Returns the +i18n_scope+ for the class. Overwrite if you want custom lookup.
    # ＃クラスの+ i18n_scope +を返します。 カスタム検索が必要な場合は上書きします。
    def i18n_scope
      :activemodel
    end

    # When localizing a string, it goes through the lookup returned by this
    # method, which is used in ActiveModel::Name#human,
    # ActiveModel::Errors#full_messages and
    # ActiveModel::Translation#human_attribute_name.

    # ＃文字列をローカライズするとき、これによって返されるルックアップを通過します
    #     ＃ActiveModel :: Name＃humanで使用されるメソッド、
    #     ＃ActiveModel :: Errors＃full_messagesおよび
    #     ＃ActiveModel :: Translation＃human_attribute_name。

    # ancestors -> [Class, Module][permalink][rdoc]
    # クラス、モジュールのスーパークラスとインクルードしているモジュールを優先順位順に配列に格納して返します。
    # https://docs.ruby-lang.org/ja/latest/method/Module/i/ancestors.html

    # model_name() 公衆
    # モジュールのActiveModel :: Nameオブジェクトを返します。すべての種類のネーミング関連情報を取得するために使用できます
    # https://apidock.com/rails/ActiveModel/Naming/model_name
    def lookup_ancestors
      # ActiveModelのクラス、モジュールの名前文字列Nameオブジェクトを全て返す
      ancestors.select { |x| x.respond_to?(:model_name) }
    end

    # Transforms attribute names into a more human format, such as "First name"
    # instead of "first_name".
    #
    #   Person.human_attribute_name("first_name") # => "First name"
    #
    # Specify +options+ with additional translating options.

    # ＃属性名を「名」などのより人間的な形式に変換します
    #     ＃「first_name」の代わり。
    #     ＃
    #     ＃Person.human_attribute_name（ "first_name"）＃=> "名"
    #     ＃
    #     ＃追加の翻訳オプションで+ options +を指定します。
    #
    # （たぶんYamlに渡すための）変換対象の翻訳パス文字列を集約してactivesupport/lib/active_support/i18n_railtie.rbに渡す
    def human_attribute_name(attribute, options = {})
      options   = { count: 1 }.merge!(options)
      parts     = attribute.to_s.split(".")
      attribute = parts.pop
      namespace = parts.join("/") unless parts.empty?
      attributes_scope = "#{i18n_scope}.attributes"

      # a = :"aaa"; a => :aaa
      if namespace
        defaults = lookup_ancestors.map do |klass|
          :"#{attributes_scope}.#{klass.model_name.i18n_key}/#{namespace}.#{attribute}"
        end
        defaults << :"#{attributes_scope}.#{namespace}.#{attribute}"
      else
        defaults = lookup_ancestors.map do |klass|
          :"#{attributes_scope}.#{klass.model_name.i18n_key}.#{attribute}"
        end
      end

      defaults << :"attributes.#{attribute}"
      defaults << options.delete(:default) if options[:default]
      defaults << attribute.humanize

      options[:default] = defaults
      I18n.translate(defaults.shift, **options)
    end
  end
end
