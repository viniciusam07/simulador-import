class AddStatusToSimulations < ActiveRecord::Migration[7.1]
  def change
    add_column :simulations, :status, :string, null: false, default: 'draft'
  end
end
