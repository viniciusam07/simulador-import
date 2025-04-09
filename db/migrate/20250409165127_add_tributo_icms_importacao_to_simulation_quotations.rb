class AddTributoIcmsImportacaoToSimulationQuotations < ActiveRecord::Migration[7.1]
  def change
    add_column :simulation_quotations, :tributo_icms_importacao, :decimal, precision: 10, scale: 2
  end
end
