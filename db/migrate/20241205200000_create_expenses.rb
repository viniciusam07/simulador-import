class CreateExpenses < ActiveRecord::Migration[7.1]
  def change
    create_table :expenses do |t|
      t.string :expense_name, null: false
      t.text :expense_description
      t.decimal :expense_default_value, precision: 10, scale: 2
      t.string :expense_currency, null: false
      t.string :expense_location, null: false

      t.timestamps
    end
  end
end
