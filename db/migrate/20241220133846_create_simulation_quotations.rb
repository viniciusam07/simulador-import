class CreateSimulationQuotations < ActiveRecord::Migration[7.1]
  def change
    create_table :simulation_quotations do |t|
      t.references :simulation, null: false, foreign_key: true
      t.references :quotation, null: false, foreign_key: true

      t.timestamps
    end
  end
end
