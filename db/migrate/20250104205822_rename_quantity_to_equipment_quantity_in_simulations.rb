class RenameQuantityToEquipmentQuantityInSimulations < ActiveRecord::Migration[7.1]
  def change
    rename_column :simulations, :quantity, :equipment_quantity
  end
end
