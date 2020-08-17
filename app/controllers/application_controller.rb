class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper           # モジュールを読み込ませる どのコントローラでもヘルパーに定義したメソッドが使える
  
  
  $days_of_the_week = %w{日 月 火 水 木 金 土}  # グローバル変数 リテラル表記
  
  
  # ページ出力前に1ヶ月分のデータの存在を確認・セットします。
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
end
  # 「まとめてデータを保存や更新するときに、全部成功したことを保証するための機能」
  # 万が一途中で失敗した時は、エラー発生時専用のプログラム部分までスキップする」
