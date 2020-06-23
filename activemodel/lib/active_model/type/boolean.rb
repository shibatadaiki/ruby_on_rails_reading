# frozen_string_literal: true

module ActiveModel
  module Type
    #＃==アクティブな\ Model \ Type \ Boolean
    #＃
    #＃ユーザー入力の強制に関するルールを含む、ブール型のように動作するクラス。
    #＃
    #＃===強制
    #＃ユーザー入力から設定された値は、最初に適切なルビ型に強制変換されます。
    #＃強制動作は、Rubyのブールセマンティクスに大まかにマッピングされます。
    #＃
    #＃-"false"、 "f"、 "0"、+ 0+、または+ FALSE_VALUES +の他の値は+ false +に強制変換されます
    #＃-空の文字列は+ nil +に強制変換されます
    #＃-他のすべての値は+ true +に強制されます
    class Boolean < Value
      # これらをfalseとして扱う
      FALSE_VALUES = [
        false, 0,
        "0", :"0",
        "f", :f,
        "F", :F,
        "false", :false,
        "FALSE", :FALSE,
        "off", :off,
        "OFF", :OFF,
      ].to_set.freeze

      def type # :nodoc:
        :boolean
      end

      def serialize(value) # :nodoc:
        cast(value)
      end

      private
        # cast例
        # https://qiita.com/natsuokawai/items/5ac1a9704805ff17b3f2
        #
        # [3] pry(main)> c.checked
        #  => false
        #[4] pry(main)> c.checked = 1
        #  => 1
        #[5] pry(main)> c.checked
        #  => true (数字がT/Fにキャストされている)
        #[6] pry(main)> c.checked = "off"
        #  => "off"
        #[7] pry(main)> c.checked
        #  => false (文字列が特殊な加工を経てT/Fにキャストされている)
        def cast_value(value)
          if value == ""
            nil
          else
            !FALSE_VALUES.include?(value)
          end
        end
    end
  end
end
