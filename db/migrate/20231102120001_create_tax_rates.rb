class CreateTaxRates < ActiveRecord::Migration[6.0]
  def change
    create_table :tax_rates do |t|
      t.references :tax, null: false, foreign_key: true
      t.string :ncm, null: false
      t.decimal :rate, precision: 5, scale: 2, null: false

      t.timestamps
    end
  end
end
