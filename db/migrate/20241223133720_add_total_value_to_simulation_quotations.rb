class AddTotalValueToSimulationQuotations < ActiveRecord::Migration[7.1]
  def change
    add_column :simulation_quotations, :total_value, :decimal
  end
end
