class AddCustomExchangeRatesAndCurrenciesToSimulations < ActiveRecord::Migration[7.1]
  def change
    add_column :simulations, :exchange_rate_goods, :decimal, precision: 10, scale: 4
    add_column :simulations, :exchange_rate_freight, :decimal, precision: 10, scale: 4
    add_column :simulations, :exchange_rate_insurance, :decimal, precision: 10, scale: 4

    add_column :simulations, :currency_freight, :string
    add_column :simulations, :currency_insurance, :string
  end
end
