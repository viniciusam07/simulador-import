class RemoveUnusedColumnsFromPortAirports < ActiveRecord::Migration[7.1]
  def change
    remove_column :port_airports, :name_without_diacritics, :string
    remove_column :port_airports, :status, :string
    remove_column :port_airports, :iata, :string
  end
end
