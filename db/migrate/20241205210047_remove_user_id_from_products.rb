class RemoveUserIdFromProducts < ActiveRecord::Migration[7.1]
  def change
    remove_column :products, :user_id, :bigint
  end
end
