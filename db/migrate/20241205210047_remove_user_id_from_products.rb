class RemoveUserIdFromProducts < ActiveRecord::Migration[7.1]
  def change
    if column_exists?(:products, :user_id)
      remove_column :products, :user_id, :bigint
    end
  end
end
