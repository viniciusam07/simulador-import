class CreateProducts < ActiveRecord::Migration[7.1]
  def change
    create_table :products do |t|
      t.string :product_name
      t.string :hs_code
      t.string :ncm
      t.string :unit_of_measure
      t.integer :quantity_per_box
      t.decimal :unit_net_weight
      t.decimal :unit_price

      t.timestamps
    end
  end
end
