class AddExchangeRateToSimulations < ActiveRecord::Migration[7.1]
  def change
    add_column :simulations, :exchange_rate, :decimal
  end
end
