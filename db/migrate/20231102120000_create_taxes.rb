class CreateTaxes < ActiveRecord::Migration[6.0]
  def change
    create_table :taxes do |t|
      t.string :name, null: false
      t.text :description

      t.timestamps
    end
  end
end
