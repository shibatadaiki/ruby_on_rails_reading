# done

# frozen_string_literal: true

module ActiveModel
  module Validations
    #＃パスワードまたは電子メールを検証するパターンをカプセル化
    class ConfirmationValidator < EachValidator # :nodoc:
      def initialize(options)
        super({ case_sensitive: true }.merge!(options))
        setup!(options[:class])
      end

      def validate_each(record, attribute, value)
        unless (confirmed = record.send("#{attribute}_confirmation")).nil?
          # confirmation_value_equal? -> 二つの値が同じでなければ
          unless confirmation_value_equal?(record, attribute, value, confirmed)
            human_attribute_name = record.class.human_attribute_name(attribute)
            record.errors.add(:"#{attribute}_confirmation", :confirmation, **options.except(:case_sensitive).merge!(attribute: human_attribute_name))
          end
        end
      end

      private
        def setup!(klass)
          # 検証属性を動的に定義する
          klass.attr_reader(*attributes.map do |attribute|
            :"#{attribute}_confirmation" unless klass.method_defined?(:"#{attribute}_confirmation")
          end.compact)

          klass.attr_writer(*attributes.map do |attribute|
            :"#{attribute}_confirmation" unless klass.method_defined?(:"#{attribute}_confirmation=")
          end.compact)
        end

        def confirmation_value_equal?(record, attribute, value, confirmed)
          if !options[:case_sensitive] && value.is_a?(String)
            # https://docs.ruby-lang.org/ja/latest/method/String/i/casecmp.html
            # 文字列の順序を比較しますが、アルファベットの大文字小文字の違いを無視します。
            #
            # 値が一致しているか確認
            value.casecmp(confirmed) == 0
          else
            value == confirmed
          end
        end
    end

    module HelperMethods
      #＃パスワードまたは電子メールを検証するパターンをカプセル化します
      #＃確認のある住所フィールド。      #
      #
      #   Model:
      #     class Person < ActiveRecord::Base
      #       validates_confirmation_of :user_name, :password
      #       validates_confirmation_of :email_address,
      #                                 message: 'should match confirmation'
      #     end
      #
      #   View:
      #     <%= password_field "person", "password" %>
      #     <%= password_field "person", "password_confirmation" %>
      #
      # ＃追加された+ password_confirmation +属性は仮想です。存在するだけ
      #      ＃パスワードを検証するためのメモリ内属性として。これを達成するために、
      #      ＃検証は確認のためにモデルにアクセサーを追加します
      #      ＃属性。
      #      ＃
      #      ＃注：このチェックは、+ password_confirmation +がない場合にのみ実行されます
      #      ＃+ nil +。確認を要求するには、必ず存在チェックを追加してください
      #      ＃確認属性：
      #      ＃
      #      ＃validates_presence_of：password_confirmation、if：：password_changed？
      #      ＃
      #      ＃設定オプション：
      #      ＃* <tt>：message </ tt>-カスタムエラーメッセージ（デフォルトは「一致しない」
      #      ＃<tt>％{translated_attribute_name} </ tt> "）。
      #      ＃* <tt>：case_sensitive </ tt>-完全に一致するものを探します。無視される
      #      ＃非テキスト列（デフォルトは+ true +）。
      #      ＃
      #      ＃すべてのバリデーターがサポートするデフォルトのオプションのリストもあります：
      #      ＃+：if +、+：unless +、+：on +、+：allow_nil +、+：allow_blank +、+：strict +。
      #      ＃詳細は、<tt> ActiveModel :: Validations＃validates </ tt>を参照してください
      def validates_confirmation_of(*attr_names)
        validates_with ConfirmationValidator, _merge_attributes(attr_names)
      end
    end
  end
end
