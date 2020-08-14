class SessionsController < ApplicationController
  def new
  end
  
  def create
    user = User.find_by(email: params[:session][:email].downcase)  # ログインフォームからのemailの値でユーザーオブジェクトを検索
    if user && user.authenticate(params[:session][:password])      # authenticateメソッドはパスワードの認証
      log_in user                     # module SessionsHelper      # &&は取得したユーザーオブジェクトが有効か判定
      params[:session][:remember_me] == '1' ? remember(user) : forget(user)  # チェックボックスがオン　オフ
      redirect_back_or user                         # userを指定することで、デフォルトのURLを設定 フレンドリーフォワーディング      
    else
      flash.now[:danger] = '認証に失敗しました。'                  # リダイレクトはしないがフラッシュを表示したい
      render :new
    end
  end 
  
  
  def destroy
    # ログイン中の場合のみログアウト処理を実行します。
    log_out if logged_in?                      # module SessionsHelper
    flash[:success] = 'ログアウトしました。'
    redirect_to root_url
  end
end
