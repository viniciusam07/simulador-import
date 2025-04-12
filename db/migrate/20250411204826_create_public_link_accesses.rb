class CreatePublicLinkAccesses < ActiveRecord::Migration[7.1]
  def change
    create_table :public_link_accesses do |t|
      t.references :public_link, null: false, foreign_key: true
      t.string :ip
      t.text :user_agent
      t.string :city
      t.string :country
      t.datetime :accessed_at
      t.integer :session_duration

      t.timestamps
    end
  end
end
