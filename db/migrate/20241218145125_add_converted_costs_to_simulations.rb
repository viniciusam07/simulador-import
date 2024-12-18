class AddConvertedCostsToSimulations < ActiveRecord::Migration[7.1]
  def change
    add_column :simulations, :freight_cost_brl, :decimal, precision: 10, scale: 2
    add_column :simulations, :insurance_cost_brl, :decimal, precision: 10, scale: 2
    add_column :simulations, :total_value_brl, :decimal, precision: 10, scale: 2
  end
end
