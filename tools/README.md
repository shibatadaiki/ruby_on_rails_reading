# done

# Rails dev tools

This is a collection of utilities used for Rails internal development.
They aren't used by Rails apps directly.

  * `console` drops you in irb and loads local Rails repos
  * `profile` profiles `Kernel#require` to help reduce startup time
  * `line_statistics` provides CodeTools module and LineStatistics class to count lines
  * `test` is loaded by every major component of Rails to simplify testing, for example:
    `cd ./actioncable; bin/test ./path/to/actioncable_test_with_line_number.rb:5`

＃Rails開発ツール

これは、Railsの内部開発に使用されるユーティリティのコレクションです。
Railsアプリでは直接使用されません。

   * `console`はirbにドロップし、ローカルのRailsリポジトリをロードします
   * `profile`は起動時間を短縮するために` Kernel＃require`をプロファイルします
   * `line_statistics`は、CodeToolsモジュールとLineStatisticsクラスを提供して行をカウントします
   * `test`はRailsのすべての主要コンポーネントによってロードされ、テストを簡略化します。次に例を示します。
     `cd ./actioncable; bin / test ./path/to/actioncable_test_with_line_number.rb：5`