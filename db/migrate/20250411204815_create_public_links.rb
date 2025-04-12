class CreatePublicLinks < ActiveRecord::Migration[7.1]
  def change
    create_table :public_links do |t|
      t.references :simulation, null: false, foreign_key: true
      t.string :token, null: false
      t.datetime :accessed_at
      t.datetime :expires_at

      t.timestamps
    end
    add_index :public_links, :token, unique: true
  end
end
