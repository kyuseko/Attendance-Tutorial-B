class User < ApplicationRecord
  has_many :attendances, dependent: :destroy
  # 「remember_token」という仮想の属性を作成します。
  attr_accessor :remember_token               # user.remember_tokenメソッドを使える
  
  before_save { self.email = email.downcase }  # 現在のメールアドレス（self.email）の値をdowncaseメソッドを使って小文字に変換
  
  validates :name,  presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i      # 正規表現でメールアドレスのフォーマットを検証できる
  validates :email, presence: true, length: { maximum: 100 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: true                            # 一意性の検証 他に同じデータがない
  validates :department, length: { in: 2..30 }, allow_blank: true   # 値が空文字""の場合バリデーションをスルー
  validates :basic_time, presence: true
  validates :work_time, presence: true
  has_secure_password                        # パスワードハッシュ化
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true  #編集時 パスワードはスルーして更新
 
  
  # 渡された文字列のハッシュ値を返します。
  def User.digest(string)
    cost = 
      if ActiveModel::SecurePassword.min_cost
        BCrypt::Engine::MIN_COST
      else
        BCrypt::Engine.cost
      end
    BCrypt::Password.create(string, cost: cost)
  end


  # ランダムなトークンを返します。
  def User.new_token
    SecureRandom.urlsafe_base64
  end                            # ランダムに生成したトークンをハッシュ化（ダイジェストとして保存するため）する準備は整いました
  
  
  # 永続セッションのためハッシュ化したトークンをデータベースに記憶します。
  def remember
    self.remember_token = User.new_token       # ハッシュ化されたトークン情報」を代入
    update_attribute(:remember_digest, User.digest(remember_token))  # トークンダイジェストを更新
  end
  
  
  # トークンがダイジェストと一致すればtrueを返します。
  # cookiesに保存されているremember_tokenがDBにあるremember_digestと一致することを確認 トークン認証
  def authenticated?(remember_token)
  # ダイジェストが存在しない場合はfalseを返して終了します。
  return false if remember_digest.nil?
  BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end
  
  
  # ユーザーのログイン情報を破棄します。 永続的セッションを終了
  def forget
    update_attribute(:remember_digest, nil)
  end
  
  
  def self.search(search)  # メソッドはコントローラから呼び出すもの
      if search
        where(['name LIKE ?', "%#{search}%"])  # 文字列を検索 Userテーブルのカラム(name)から(LIKE)、検索ワード(search)にかする文字列はないか見ている
      else
        all  # 検索ワードが無い場合に、Userテーブルから全てのレコードを返す
      end
  end
end