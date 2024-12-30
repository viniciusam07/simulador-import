class AddCfopFieldsToSimulations < ActiveRecord::Migration[7.1]
  def change
    add_column :simulations, :cfop_code, :string
    add_column :simulations, :cfop_description, :string
  end
end
