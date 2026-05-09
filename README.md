# choice-book-search-lambda
技術書選びの検索 API（AWS Lambda デプロイ用）

## Ruby バージョン

Ruby 3.3.6（AWS Lambda の `ruby3.3` ランタイムに合わせる）

## 環境変数

楽天ウェブサービスの新インフラ（2026/5/14〜）に対応するため、以下を Lambda の環境変数に設定する。

- `RWS_APPLICATION_ID` … 楽天ウェブサービスで再登録したアプリの applicationId
- `RWS_ACCESS_KEY` … 同アプリの accessKey（リクエストヘッダで送信）
- `RWS_AFFILIATE_ID` … アフィリエイトID（任意）

## リリースフロー

- Gem の変更を行なったとき

```
bundle install --path vendor/bundle
```

- ファイルの圧縮

```
zip -r function.zip lambda_function.rb rakuten_search.rb rakuten_book_display.rb rakuten_book_api_service.rb vendor
```

- AWS コンソールの Lambda の画面から `function.zip` をアップロード
