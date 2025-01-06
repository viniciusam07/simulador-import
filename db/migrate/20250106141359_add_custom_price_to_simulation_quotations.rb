class AddCustomPriceToSimulationQuotations < ActiveRecord::Migration[7.1]
  def change
    add_column :simulation_quotations, :custom_price, :decimal, precision: 10, scale: 2
  end
end
