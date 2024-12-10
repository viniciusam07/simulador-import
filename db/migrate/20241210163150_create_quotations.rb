class CreateQuotations < ActiveRecord::Migration[7.1]
  def change
    create_table :quotations do |t|
      t.references :product, null: false, foreign_key: true
      t.references :supplier, null: false, foreign_key: true
      t.decimal :price, precision: 10, scale: 2, null: false
      t.string :currency, null: false
      t.date :validity, null: false
      t.integer :moq, null: false # Minimum Order Quantity
      t.string :payment_terms, null: false
      t.integer :lead_time # Estimated delivery time in days
      t.timestamps
    end
  end
end
