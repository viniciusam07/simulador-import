class CreateSimulationTaxes < ActiveRecord::Migration[6.0]
  def change
    create_table :simulation_taxes do |t|
      t.references :simulation, null: false, foreign_key: true
      t.references :tax, null: false, foreign_key: true
      t.decimal :calculated_value, precision: 10, scale: 2, null: false

      t.timestamps
    end
  end
end
