done

バージョンチェンジ時の差分をここに書き込んでるみたい。
`ActiveModel`の` errors`コレクションがエラーの配列になったり `errors＃slice！`とか`errors＃values`とかのメソッドが消失したり
データベースによってサポートされていない属性を、凍結されているオブジェクトに書き込もうとすると、FrozenErrorが発生します。
-> 今までならなかったのかな？？

ーーーーーーーーーーーーーーーー以下日本語訳ーーーーーーーーーーーーーーーー

* `* _previously_changed？`は、 `：_changed？`のような `：from`および`：to`キーワード引数を受け入れます。
        topic.update！（status：：archived）
        topic.status_previously_changed？（from： "active"、to： "archived"）
        ＃=> true
    *ジョージクラグホーン*
*データベースによってサポートされていない属性を、凍結されているオブジェクトに書き込もうとすると、FrozenErrorが発生します。
        クラス動物
          ActiveModel :: Attributesを含める
          属性：年齢
        終わり
        animal = Animal.new
        animal.freeze
        animal.age = 25＃=> FrozenError、「凍結された動物は変更できません」
    *ジョシュ・ブロディ*
*ダーティトラッキングの際に `* _previously_was`属性メソッドを追加します。例：
        pirate.update（キャッチフレーズ： "Ahoy！"）
        pirate.previous_changes ["catchphrase"]＃=> ["Thar She Blows！"、 "Ahoy！"]
        pirate.catchphrase_previously_was＃=> "Thar She Blows！"
    * DHH *
*各検証エラーをErrorオブジェクトとしてカプセル化します。
    `ActiveModel`の` errors`コレクションはこれらのエラーの配列になりました
    メッセージ/詳細ハッシュの代わりにオブジェクト。
    これらの各 `Error`オブジェクト、その` message`および `full_message`メソッド
    エラーメッセージを生成するためのものです。その `details`メソッドはエラーを返します
    元の `details`ハッシュにある追加のパラメーター。
    この変更は、下位互換性を維持するために最善を尽くしていますが、
    `errors＃first`が` ActiveModel :: Error`を返し、操作するなど、一部のエッジケースはカバーされません
    `errors.messages`と` errors.details`の直接のハッシュは効果がありません。今後、
    これらの直接操作を変換して、代わりに提供されたAPIメソッドを使用してください。
    非推奨のメソッドと、次のメジャーリリースで予定されている将来の動作変更のリストは次のとおりです。
    * `errors＃slice！`は削除されます。
    * `key、value`の2つの引数ブロックを含む` errors＃each`は機能を停止しますが、 `error`の単一引数ブロックは` Error`オブジェクトを返します。
    * `errors＃values`は削除されます。
    * `errors＃keys`は削除されます。
    * `errors＃to_xml`は削除されます。
    * `errors＃to_h`は削除され、` errors＃to_hash`に置き換えることができます。
    * `errors`自体をハッシュとして操作しても効果はありません（例：` errors [：foo] = 'bar'`）。
    * `errors＃messages`によって返されたハッシュ（たとえば、` errors.messages [：foo] = 'bar'`）を操作しても効果はありません。
    * `errors＃details`によって返されたハッシュ（たとえば、` errors.details [：foo] .clear`）を操作しても効果はありません。
    *ルラララ*
以前の変更については、[6-0-stable]（https://github.com/rails/rails/blob/6-0-stable/activemodel/CHANGELOG.md）を確認してください。

ーーーーーーーーーーーーーーーー以上日本語訳ーーーーーーーーーーーーーーーー

*   `*_previously_changed?` accepts `:from` and `:to` keyword arguments like `*_changed?`.

        topic.update!(status: :archived)
        topic.status_previously_changed?(from: "active", to: "archived")
        # => true

    *George Claghorn*

*   Raise FrozenError when trying to write attributes that aren't backed by the database on an object that is frozen:

        class Animal
          include ActiveModel::Attributes
          attribute :age
        end

        animal = Animal.new
        animal.freeze
        animal.age = 25 # => FrozenError, "can't modify a frozen Animal"

    *Josh Brody*

*   Add `*_previously_was` attribute methods when dirty tracking. Example:

        pirate.update(catchphrase: "Ahoy!")
        pirate.previous_changes["catchphrase"] # => ["Thar She Blows!", "Ahoy!"]
        pirate.catchphrase_previously_was # => "Thar She Blows!"

    *DHH*

*   Encapsulate each validation error as an Error object.

    The `ActiveModel`’s `errors` collection is now an array of these Error
    objects, instead of messages/details hash.

    For each of these `Error` object, its `message` and `full_message` methods
    are for generating error messages. Its `details` method would return error’s
    extra parameters, found in the original `details` hash.

    The change tries its best at maintaining backward compatibility, however
    some edge cases won’t be covered, like `errors#first` will return `ActiveModel::Error` and manipulating
    `errors.messages` and `errors.details` hashes directly will have no effect. Moving forward,
    please convert those direct manipulations to use provided API methods instead.

    The list of deprecated methods and their planned future behavioral changes at the next major release are:

    * `errors#slice!` will be removed.
    * `errors#each` with the `key, value` two-arguments block will stop working, while the `error` single-argument block would return `Error` object.
    * `errors#values` will be removed.
    * `errors#keys` will be removed.
    * `errors#to_xml` will be removed.
    * `errors#to_h` will be removed, and can be replaced with `errors#to_hash`.
    * Manipulating `errors` itself as a hash will have no effect (e.g. `errors[:foo] = 'bar'`).
    * Manipulating the hash returned by `errors#messages` (e.g. `errors.messages[:foo] = 'bar'`) will have no effect.
    * Manipulating the hash returned by `errors#details` (e.g. `errors.details[:foo].clear`) will have no effect.

    *lulalala*


Please check [6-0-stable](https://github.com/rails/rails/blob/6-0-stable/activemodel/CHANGELOG.md) for previous changes.
