class CreatePortAirports < ActiveRecord::Migration[7.1]
  def change
    create_table :port_airports do |t|
      t.string :country, null: false
      t.string :location, null: false
      t.string :name, null: false
      t.string :name_without_diacritics
      t.string :status
      t.string :iata
      t.decimal :latitude, precision: 10, scale: 6
      t.decimal :longitude, precision: 10, scale: 6
      t.jsonb :function_array, default: []
      t.jsonb :function_description, default: []

      t.timestamps
    end

    add_index :port_airports, :location
  end
end
