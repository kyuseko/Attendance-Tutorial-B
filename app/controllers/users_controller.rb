class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :edit_basic_info, :update_basic_info]        # @userをセットする
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy, :edit_basic_info, :update_basic_info]   # ログインを要求
  before_action :correct_user, only: [:edit, :update]            # 正しいユーザーであることを要求 ユーザー自身のみが情報を編集・更新できる
  before_action :admin_user, only: [:destroy, :edit_basic_info, :update_basic_info]       # 管理者のみ削除
  before_action :set_one_month, only: :show  # # ページ出力前に1ヶ月分のデータの存在を確認・セットします。1ヶ月分のデータが無い状態を防ぐ
  before_action :admin_or_correct_user, only: :show


  def index
    @users = User.paginate(page: params[:page])  # ページネーション
    if params[:search].present?
      @users = @users.search(params[:search])
    end 
  end

  def show 
   @worked_sum = @attendances.where.not(started_at: nil).count  # 出勤日数を表示
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user
      flash[:success] = '新規作成に成功しました。'
      redirect_to @user
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @user.update_attributes(user_params)
      flash[:success] = "ユーザー情報を更新しました。"
      redirect_to @user
    else
      render :edit      
    end
  end

  def destroy
    @user.destroy
    flash[:success] = "#{@user.name}のデータを削除しました。"
    redirect_to users_url
  end

  def edit_basic_info
  end


  def update_basic_info
    if @user.update_attributes(basic_info_params)
      flash[:success] = "#{@user.name}の基本情報を更新しました。"
    else
      flash[:danger] = "#{@user.name}の更新は失敗しました。<br>" + @user.errors.full_messages.join("<br>")
    end
    redirect_to users_url
  end
  
  
end

