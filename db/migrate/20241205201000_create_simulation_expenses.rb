class CreateSimulationExpenses < ActiveRecord::Migration[7.1]
  def change
    create_table :simulation_expenses do |t|
      t.integer :simulation_id, null: false
      t.integer :expense_id
      t.string :expense_custom_name
      t.decimal :expense_custom_value, precision: 10, scale: 2
      t.string :expense_currency, null: false
      t.string :expense_location, null: false

      t.timestamps
    end

    add_index :simulation_expenses, :simulation_id
    add_index :simulation_expenses, :expense_id
    add_foreign_key :simulation_expenses, :simulations
    add_foreign_key :simulation_expenses, :expenses
  end
end
