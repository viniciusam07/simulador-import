class AddQuantityToSimulationQuotations < ActiveRecord::Migration[7.1]
  def change
    add_column :simulation_quotations, :quantity, :integer
  end
end
