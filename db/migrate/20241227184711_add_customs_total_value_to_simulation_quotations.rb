class AddCustomsTotalValueToSimulationQuotations < ActiveRecord::Migration[7.1]
  def change
    add_column :simulation_quotations, :customs_total_value, :decimal
  end
end
