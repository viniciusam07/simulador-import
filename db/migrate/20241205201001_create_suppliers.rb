class CreateSuppliers < ActiveRecord::Migration[7.1]
  def change
    create_table :suppliers do |t|
      t.string :corporate_name
      t.string :trade_name
      t.string :country

      t.timestamps
    end
  end
end
