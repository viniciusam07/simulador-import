class AddAliquotasToSimulationQuotations < ActiveRecord::Migration[7.1]
  def change
    add_column :simulation_quotations, :aliquota_ii, :decimal, precision: 5, scale: 2
    add_column :simulation_quotations, :aliquota_ipi, :decimal, precision: 5, scale: 2
    add_column :simulation_quotations, :aliquota_pis, :decimal, precision: 5, scale: 2
    add_column :simulation_quotations, :aliquota_cofins, :decimal, precision: 5, scale: 2
    add_column :simulation_quotations, :aliquota_icms, :decimal, precision: 5, scale: 2
  end
end
