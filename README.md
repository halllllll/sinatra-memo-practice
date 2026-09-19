## sinatra-memo-practice
Ruby の軽量Webアプリケーションライブラリ [Sinatra](https://sinatrarb.com/) を使ったアプリ開発の学習・練習用リポジトリ

## Prerequisites
- Bundler
- rbenv
- rubocop
- PostgreSQL

## Setup
this sample app uses the following database properties:

  |property||
  |--|--|
  |host|localhost|
  |port|5678 (**NOT** the default 5432)|
  |dbname|memo_db|
  |user|memo_app|
  |password|memo_pass|


DDL: [db/init.sql](./db/init.sql)

---

1. clone this repository
    - `git clone`
2. switch to the `dev` branch to test the latest implementation
    - `git checkout -b dev origin/dev`
3. prepare Ruby environment
    - `rbenv install`
4. install gems
    - `bundle install`
5. create `PGDATA` directory with password authentication.
    ```sh
    initdb --encoding=UTF8 --no-locale -A scram-sha-256 -D ./db/pg-data -W
    ```
    > [!NOTE] you will be prompted to set the database `superuser` password.

6. start the PostgreSQL server on port `5678`. (logs are written to `db/memo.log`):
    ```sh
    pg_ctl -D ./db/pg-data -l ./db/memo.log -o "-p 5678" start
    ```

7. create a database role for this app
    ```sh
    createuser -h localhost -p 5678 memo_app -d -P -e
    ```

    then enter the passwords when prompted:
    ```text
    Enter password for new role: (enter "memo_pass" for this sample)
    Enter it again: (enter "memo_pass" for this sample)
    Password: (superuser password)
    ```
8. create the database
    ```sh
    createdb -h localhost -p 5678 -O memo_app memo_db -e
    ```

## Commands

### Run the App
On startup, the app runs `db/init.sql` to create the `memos` table if it does not exist.
```sh
bundle exec puma config.ru -p 4567
```
Visit [http://localhost:4567/](http://localhost:4567/).

Memos are stored in the `memo_db` PostgreSQL database.
Puma's default port is `9292`; use `-p` to specify a different port.


### Lint / Format
- Run `erb_lint`
```sh
bundle exec erb_lint --lint-all
```

- Run `rubocop` (config: `.rubocop.yml`)
```sh
bundle exec rubocop
```
### Connect to the database with psql
```sh
psql -h localhost -p 5678 -U memo_app -d memo_db
```

### Cleanup the database
First, stop the db server:
```sh
pg_ctl -D ./db/pg-data stop
```

then remove the `db/pg-data` directory and the log file. This also removes all roles, including memo_app.



## Web UI Screenshot
### Home
![](images/home.png)
### Create
![](images/create.png)

### Detail
![](images/detail.png)

### Edit
![](images/edit.png)

### Delete
![](images/delete.png)

## API
REST-based JSON API is available under `/api`.
### Response

```json
{
  "result": "success",
  "body": ...
}
```

or, on error:

```json
{
  "result": "error",
  "message": ...
}
```

### Memo structure

|Parameter|Type|Desc|
|--|--|--|
|id|string|UUID v4|
|title|string|required|
|content|string|required|
|created_at|datetime|`YYYY-MM-DD HH:mm:SS +ZZZZ`|
|updated_at|datetime|`YYYY-MM-DD HH:mm:SS +ZZZZ`|

### GET /api/memos
List all memos.
```sh
curl localhost:4567/api/memos
```

Example response on success:
```json
{
  "result": "success",
  "body": [
    {
      "id": "429a4196-...",
      "title": "memo title",
      "content": "...",
      "created_at": "2007-08-09 12:34:56 +0900",
      "updated_at": "2007-08-09 12:34:56 +0900"
    },
    {
      "id": "7c83a067-...",
      "title": "memo title 2",
      "content": "...",
      "created_at": "2007-08-09 12:34:56 +0900",
      "updated_at": "2007-08-09 12:34:56 +0900"
    }
  ]
}
```

### POST /api/memos
Create a new memo. Requires `title` and `content`.

```sh
# simple example
curl -v -d 'title=this is new title&content=this is new content' localhost:4567/api/memos
```

Response example:
```json
{"result":"success","body":{"id":"41a5b846-8e94-4f8b-829c-e3817dbb971c","title":"this is new title","content":"this is new content","created_at":"2026-09-05 10:31:35 +0900","updated_at":"2026-09-05 10:31:35 +0900"}}
```



### GET /api/memos/:memo_id
Get a memo.

```sh
curl -v localhost:4567/api/memos/429a4196-xxxx-xxxx-xxxx-xxxxxxxxxxxx
```

### PATCH /api/memos/:memo_id
Update an existing memo. Requires `title` and `content`.
Returns `204 No Content` on success, `404` if the memo does not exist.
```sh
curl -X PATCH \
  -v -d 'title=update title&content=update content' \
  http://localhost:4567/api/memos/429a4196-xxxx-xxxx-xxxx-xxxxxxxxxxxx
```

### DELETE /api/memos/:memo_id
Delete a memo. Returns `204 No Content` on success, `404` if the memo does not exist.

```sh
curl -v -X DELETE \
  localhost:4567/api/memos/1eae8de8-xxxx-xxxx-xxxx-xxxxxxxxxxxx
```

## Troubleshooting

### bundle install error: **The running version of Bundler (4.0.x) does not match the version of the specification installed for it (4.0.10).**
This is caused by a version mismatch between `bundler` and `Gemfile.lock`. Align your bundler version with the lock file:

```sh
gem install bundler:4.0.10
bundle install
```


## References
- sinatra [Command Line](https://github.com/sinatra/sinatra#command-line)
- jeremyevans/rack-unreloader [https://github.com/jeremyevans/rack-unreloader](https://github.com/jeremyevans/rack-unreloader)
- ged/ruby-pg [https://www.deveiate.org/code/pg/README_md.html](https://www.deveiate.org/code/pg/README_md.html)
- initdb [PostgreSQL Server Applications | initdb](https://www.postgresql.org/docs/current/app-initdb.html)
- pg_ctl [PostgreSQL Server Applications | pg_ctl](https://www.postgresql.org/docs/current/app-pg-ctl.html)
- createuser [PostgreSQL Server Applications | createuser](https://www.postgresql.org/docs/current/app-createuser.html)
- createdb [PostgreSQL Server Applications | createdb](https://www.postgresql.org/docs/current/app-createdb.html)
