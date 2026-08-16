## sinatra-memo-practice
Ruby の軽量Webアプリケーションライブラリ [Sinatra](https://sinatrarb.com/) を使ったアプリ開発の学習・練習用リポジトリ

## Requirements
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

### Run Dev env

```sh
bundle exec rerun main.rb
```

### Lint (using erb_lint)
```sh
bundle exec erb_lint --lint-all
```

## References
- sinatra [Command Line](https://github.com/sinatra/sinatra#command-line)
- rerun [Usage:](https://github.com/alexch/rerun#usage)
