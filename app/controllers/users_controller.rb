class UsersController < ApplicationController

  def show
    @user = User.find(params[:id])  # ユーザーのidの取得
  end

  def new
    @user = User.new
  end
  
  def create                        # フォームの送信を受け取る
    @user = User.new(user_params)
    if @user.save
      flash[:success] = '新規作成に成功しました。'
      redirect_to @user # 保存に成功した場合は、ここに記述した処理が実行されます。
    else
      render :new
    end
  end
  
  private

    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end
end