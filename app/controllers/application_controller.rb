class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper           # モジュールを読み込ませる どのコントローラでもヘルパーに定義したメソッドが使える
end
