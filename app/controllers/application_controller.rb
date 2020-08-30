class ApplicationController < ActionController::Base  # usersコントローラでもattendancesコントローラからでも呼び出すことが出来る
  protect_from_forgery with: :exception
  include SessionsHelper           # モジュールを読み込ませる どのコントローラでもヘルパーに定義したメソッドが使える
  
  
  $days_of_the_week = %w{日 月 火 水 木 金 土}  # グローバル変数 リテラル表記
  
  # beforフィルター

    def user_params
      params.require(:user).permit(:name, :email, :department, :password, :password_confirmation)
    end
    
    
    def basic_info_params
      params.require(:user).permit(:department, :basic_time, :work_time)
    end

    # beforeフィルター

    # paramsハッシュからユーザーを取得します。
    def set_user
      @user = User.find(params[:id])
    end
    

    # ログイン済みのユーザーか確認します。
    def logged_in_user
      unless logged_in?
        store_location
        flash[:danger] = "ログインしてください。"
        redirect_to login_url
      end
    end

    # アクセスしたユーザーが現在ログインしているユーザーか確認します。
    def correct_user
      redirect_to(root_url) unless current_user?(@user)
    end

    # システム管理権限所有かどうか判定します。
    def admin_user
      redirect_to root_url unless current_user.admin?
    end
  
  
  # ページ出力前に1ヶ月分のデータの存在を確認・セットします。1ヶ月分のデータが無い状態を防ぐ
  # paramsハッシュにdateキーを含めることが出来きたからparams[:date]から表示したい1ヶ月の情報
  def set_one_month 
    @first_day = params[:date].nil? ?
    Date.current.beginning_of_month : params[:date].to_date
    @last_day = @first_day.end_of_month
    one_month = [*@first_day..@last_day] # 対象の月の日数を代入します。
    # ユーザーに紐付く一ヶ月分のレコードを検索し取得します。
    @attendances = @user.attendances.where(worked_on: @first_day..@last_day).order(:worked_on)

    unless one_month.count == @attendances.count # それぞれの件数（日数）が一致するか評価します。
      ActiveRecord::Base.transaction do # トランザクションを開始します。データの整合性を保つため
        # 繰り返し処理により、1ヶ月分の勤怠データを生成します。
        one_month.each { |day| @user.attendances.create!(worked_on: day) }
      end
      @attendances = @user.attendances.where(worked_on: @first_day..@last_day).order(:worked_on)
      # Attendanceモデルの配列をworked_onの値をもとに昇順に並び替え
    end
    
   # 例外処理が発生
  rescue ActiveRecord::RecordInvalid # トランザクションによるエラーの分岐です。
    flash[:danger] = "ページ情報の取得に失敗しました、再アクセスしてください。"
    redirect_to root_url
  end
  
  # 管理権限者、または現在ログインしているユーザーを許可します。
    def admin_or_correct_user
      @user = User.find(params[:user_id]) if @user.blank?
      unless current_user?(@user) || current_user.admin?  # どちらかの条件式がtrueか、どちらもtrueの時には何も実行されない処理
        flash[:danger] = "編集権限がありません。"
        redirect_to(root_url)
      end  
    end
end
  # 「まとめてデータを保存や更新するときに、全部成功したことを保証するための機能」
  # 万が一途中で失敗した時は、エラー発生時専用のプログラム部分までスキップする」
