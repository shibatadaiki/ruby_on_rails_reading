done

# Action Mailbox

Action Mailbox routes incoming emails to controller-like mailboxes for processing in Rails. It ships with ingresses for Mailgun, Mandrill, Postmark, and SendGrid. You can also handle inbound mails directly via the built-in Exim, Postfix, and Qmail ingresses.

The inbound emails are turned into `InboundEmail` records using Active Record and feature lifecycle tracking, storage of the original email on cloud storage via Active Storage, and responsible data handling with on-by-default incineration.

These inbound emails are routed asynchronously using Active Job to one or several dedicated mailboxes, which are capable of interacting directly with the rest of your domain model.

You can read more about Action Mailbox in the [Action Mailbox Basics](https://edgeguides.rubyonrails.org/action_mailbox_basics.html) guide.

## License

Action Mailbox is released under the [MIT License](https://opensource.org/licenses/MIT).

＃アクションメールボックス

アクションメールボックスは、受信メールをコントローラーのようなメールボックスにルーティングしてRailsで処理します。 Mailgun、Mandrill、Postmark、SendGridのIngressが同梱されています。 組み込みのExim、Postfix、およびQmailのイングレスを介して、受信メールを直接処理することもできます。

受信メールは、Active Recordと機能のライフサイクル追跡、Active Storageを介したクラウドストレージへの元のメールの保存、デフォルトでの焼却による責任あるデータ処理を使用して、 `InboundEmail`レコードに変換されます。

これらの受信メールは、アクティブジョブを使用して非同期で1つまたは複数の専用メールボックスにルーティングされます。専用メールボックスは、ドメインモデルの残りの部分と直接対話することができます。

アクションメールボックスの詳細については、[アクションメールボックスの基本]（https://edgeguides.rubyonrails.org/action_mailbox_basics.html）ガイドをご覧ください。

##ライセンス

アクションメールボックスは、[MITライセンス]（https://opensource.org/licenses/MIT）に基づいてリリースされます。