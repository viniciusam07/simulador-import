class AddAllTaxFieldsToSimulations < ActiveRecord::Migration[6.0]
  def change
    change_table :simulations do |t|
      t.decimal :aliquota_ii, precision: 5, scale: 2
      t.decimal :tributo_ii, precision: 10, scale: 2
      t.decimal :aliquota_ipi, precision: 5, scale: 2
      t.decimal :tributo_ipi, precision: 10, scale: 2
      t.decimal :aliquota_pis, precision: 5, scale: 2
      t.decimal :tributo_pis, precision: 10, scale: 2
      t.decimal :aliquota_cofins, precision: 5, scale: 2
      t.decimal :tributo_cofins, precision: 10, scale: 2
      t.decimal :aliquota_icms, precision: 5, scale: 2
      t.decimal :tributo_icms, precision: 10, scale: 2
    end
  end
end
