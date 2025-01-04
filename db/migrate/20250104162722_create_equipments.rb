class CreateEquipments < ActiveRecord::Migration[7.1]
  def change
    create_table :equipments do |t|
      t.string :name, null: false
      t.string :container_type, null: false
      t.float :capacity
      t.integer :max_weight
      t.text :description

      t.timestamps
    end
  end
end
