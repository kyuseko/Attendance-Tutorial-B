class AddAdminToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :admin, :boolean, default: false  # デフォルトでは管理権限を持たない
  end
end
