# choice-book-search-lambda
技術書選びの検索 API（AWS Lambda デプロイ用）

## リリースフロー

- Gem の変更を行なったとき

```
bundle install --path vendor/bundle
```

- ファイルの圧縮

```
zip -r function.zip lambda_function.rb amazon_book.rb amazon_book_display.rb amazon_get_item.rb amazon_get_review.rb vendor
```

- AWS コンソールの Lambda の画面から `function.zip` をアップロード
