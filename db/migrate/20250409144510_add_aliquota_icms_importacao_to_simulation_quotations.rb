class AddAliquotaIcmsImportacaoToSimulationQuotations < ActiveRecord::Migration[7.1]
  def change
    add_column :simulation_quotations, :aliquota_icms_importacao, :decimal, precision: 5, scale: 2
  end
end
