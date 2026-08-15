# frozen_string_literal: true

require 'sinatra'

# TODO： 開発環境と本番環境でそれぞれに必要な情報やコマンドのふろーを整理する
#       今はSinatraの :development を明示的にコードに残すか、コマンドオプションや環境変数なんかで切り替えるようにするか思案中
# set :environment, :development

get '/' do
  erb :'index.html'
end
