module ApplicationHelper

  def full_title(page_name = "")
    base_title = "AttendanceApp"
    if page_name.empty?            # page_nameが空文字かどうか
      base_title
    else                           # 引数page_nameが空文字ではない場合
      page_name + " | " + base_title  # 文字列を連結して返す
    end
  end
end