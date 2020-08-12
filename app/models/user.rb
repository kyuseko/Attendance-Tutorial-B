class User < ApplicationRecord
  before_save { self.email = email.downcase }  # 現在のメールアドレス（self.email）の値をdowncaseメソッドを使って小文字に変換
  
  validates :name,  presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i      # 正規表現でメールアドレスのフォーマットを検証できる
  validates :email, presence: true, length: { maximum: 100 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: true                            # 一意性の検証 他に同じデータがない
  has_secure_password                        # パスワードハッシュ化
  validates :password, presence: true, length: { minimum: 6 }
end