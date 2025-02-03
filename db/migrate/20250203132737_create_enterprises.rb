class CreateEnterprises < ActiveRecord::Migration[7.1]
  def change
    create_table :enterprises do |t|
      t.string :name, null: false
      t.string :cnpj, null: false
      t.string :phone
      t.string :contact
      t.references :user, null: false, foreign_key: true # Criador da empresa

      t.timestamps
    end

    add_index :enterprises, :cnpj, unique: true
  end
end
