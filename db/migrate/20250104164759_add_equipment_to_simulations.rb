class AddEquipmentToSimulations < ActiveRecord::Migration[7.1]
  def change
    add_column :simulations, :equipment_id, :integer, null: true
    add_column :simulations, :quantity, :integer, null: true
    add_foreign_key :simulations, :equipments, column: :equipment_id
  end
end
