module SessionsHelper

  # 様々な場所で使いまわせるようにSessionsヘルパーモジュールにlog_inメソッドを定義
  # 引数に渡されたユーザーオブジェクトでログインします。
  def log_in(user)                         # ユーザーIDを一時的セッションの中に安全に記憶
    session[:user_id] = user.id
  end
  
  
  # 永続的セッションを記憶します（Userモデルを参照）
  # ログインするユーザーはブラウザで有効な記憶トークンを取得できるよう記録
  def remember(user)
    user.remember                                             # ハッシュ化したトークン
    cookies.permanent.signed[:user_id] = user.id              # 暗号化ユーザーIDを保存
    cookies.permanent[:remember_token] = user.remember_token  # 永続セッションを作成
  end
  
  
  # 永続的セッションを破棄します
  def forget(user)
    user.forget # Userモデル参照
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end
  
  
  # セッションと@current_userを破棄します
  def log_out
    forget(current_user)
    session.delete(:user_id)
    @current_user = nil
  end
  
  # 一時的セッションにいるユーザーを返します。
  # それ以外の場合はcookiesにいるユーザーを返します。
  def current_user
    if (user_id = session[:user_id])
      @current_user ||= User.find_by(id: user_id)
    elsif (user_id = cookies.signed[:user_id])
      user = User.find_by(id: user_id)
      if user && user.authenticated?(cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end
  
  
  # 現在ログイン中のユーザーがいればtrue、そうでなければfalseを返します。
  def logged_in?
    !current_user.nil?
  end
end
