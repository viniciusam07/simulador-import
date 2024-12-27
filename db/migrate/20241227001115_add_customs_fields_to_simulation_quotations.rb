class AddCustomsFieldsToSimulationQuotations < ActiveRecord::Migration[7.1]
  def change
    add_column :simulation_quotations, :freight_allocated, :decimal
    add_column :simulation_quotations, :insurance_allocated, :decimal
    add_column :simulation_quotations, :customs_unit_value, :decimal
    add_column :simulation_quotations, :customs_total_value, :decimal
  end
end
