class CreateNcmCodes < ActiveRecord::Migration[7.1]
  def change
    create_table :ncm_codes do |t|
      t.string :code
      t.text :description

      t.timestamps
    end
  end
end
