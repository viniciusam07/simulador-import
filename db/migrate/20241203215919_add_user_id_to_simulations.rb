class AddUserIdToSimulations < ActiveRecord::Migration[7.1]
  def change
    add_column :simulations, :user_id, :integer
  end
end
