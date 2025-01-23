class CreateSteps < ActiveRecord::Migration[7.1]
  def change
    create_table :steps do |t|
      t.string :name, null: false
      t.string :location, null: false
      t.integer :default_sla, null: false
      t.string :icon

      t.timestamps
    end
  end
end
