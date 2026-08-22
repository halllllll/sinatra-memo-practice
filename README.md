## sinatra-memo-practice
Ruby の軽量Webアプリケーションライブラリ [Sinatra](https://sinatrarb.com/) を使ったアプリ開発の学習・練習用リポジトリ

## Prerequistes
- Bundler
- rbenv
- rubocop

## Setup
0. prepare Ruby env
1. clone this repository
    - `git clone`
2. install gems
    - `bundle install`

## commands

### Run App
```sh
bundle exec puma config.ru -p 4567
```
to change port (default `4567`) with `-p` option.


[!NOTE]
Ruby4では`rerun`が実行に失敗する

### Lint (using erb_lint)
```sh
bundle exec erb_lint --lint-all
```

## API


### Response

```json
{
  "result": "success"
  "body": ...
}
```

or, Error response with message

```json
{
  "result": "error"
  "message": ...
}
```




### Memo structure

|Parameter|Type|Desc|
|--|--|--|
|id|int||
|title|string||
|content|string|memo content|
|created_at|datetime||
|updated_at|datetime||

### GET /memos
List memos.
```json
{
  "body": [
    {
      "id": "00000",
      "title": "memo title",
      "content": "....",
      "created_at": ...,
      "updated_at": ...,
    },
    {
      "id": "00001",
      "title": "memo title",
      "content": "....",
      "created_at": ...,
      "updated_at": ...,
    },
  ]
}
```

### POST /memos
Create a new memo.
```
Content-Type: application/json

{
  "title": "memo title",
  "content": "...."
}
```

### GET /memos/\{:memo_id\}
Get a memo.

### PATCH /memos/\{:memo_id\}
Update an exists memo.

### DELETE /memos/\{:memo_id\}
Delete a memo

## References
- sinatra [Command Line](https://github.com/sinatra/sinatra#command-line)
- rack-unreloader https://github.com/jeremyevans/rack-unreloader
