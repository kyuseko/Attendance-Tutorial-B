class AddIndexToUsersEmail < ActiveRecord::Migration[5.1]
  def change                                # email属性にインデックスを追加 検索を早くする仕組み
    add_index :users, :email, unique: true  #一意性を強制
  end
end
