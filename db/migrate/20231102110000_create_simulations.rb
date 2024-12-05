class CreateSimulations < ActiveRecord::Migration[7.1]
  def change
    create_table :simulations do |t|
      t.string :origin_country
      t.decimal :total_value
      t.string :incoterm
      t.string :modal

      t.timestamps
    end
  end
end
