class SessionsController < ApplicationController
  def new
  end
  
  def create
    user = User.find_by(email: params[:session][:email].downcase)  # ログインフォームからのemailの値でユーザーオブジェクトを検索
    if user && user.authenticate(params[:session][:password])      # authenticateメソッドはパスワードの認証
      log_in user                     # module SessionsHelper      # &&は取得したユーザーオブジェクトが有効か判定
      redirect_to user       
    else
      flash.now[:danger] = '認証に失敗しました。'                  # リダイレクトはしないがフラッシュを表示したい
      render :new
    end
  end 
  
  
  def destroy
    log_out                       # module SessionsHelper
    flash[:success] = 'ログアウトしました。'
    redirect_to root_url
  end
end
