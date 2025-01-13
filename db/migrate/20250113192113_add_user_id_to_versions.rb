class AddUserIdToVersions < ActiveRecord::Migration[7.1]
  def change
    add_column :versions, :user_id, :integer
    add_index :versions, :user_id
  end
end
