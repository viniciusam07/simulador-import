class AddTransportFieldsToSimulations < ActiveRecord::Migration[7.1]
  def change
    add_column :simulations, :destination_state, :string
    add_column :simulations, :origin_port, :string
    add_column :simulations, :destination_port, :string
    add_column :simulations, :origin_airport, :string
    add_column :simulations, :destination_airport, :string
  end
end
