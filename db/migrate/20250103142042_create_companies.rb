class CreateCompanies < ActiveRecord::Migration[7.1]
  def change
    create_table :companies do |t|
      t.string :name, null: false
      t.string :cnpj, null: false
      t.string :corporate_name, null: false
      t.string :zip_code
      t.string :address
      t.string :state
      t.string :city
      t.string :segment
      t.string :company_type
      t.string :tax_regime

      t.timestamps
    end

    add_index :companies, :cnpj, unique: true
  end
end
