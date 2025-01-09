class AddFieldsToSimulations < ActiveRecord::Migration[7.1]
  def change
    add_column :simulations, :cargo_type, :string
    add_column :simulations, :observations, :text
  end
end
