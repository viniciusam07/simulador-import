class AddTaxesToSimulationQuotations < ActiveRecord::Migration[7.1]
  def change
    add_column :simulation_quotations, :tributo_ii, :decimal, precision: 10, scale: 2
    add_column :simulation_quotations, :tributo_ipi, :decimal, precision: 10, scale: 2
    add_column :simulation_quotations, :tributo_pis, :decimal, precision: 10, scale: 2
    add_column :simulation_quotations, :tributo_cofins, :decimal, precision: 10, scale: 2
    add_column :simulation_quotations, :tributo_icms, :decimal, precision: 10, scale: 2
  end
end
