class AddCurrencyToSimulations < ActiveRecord::Migration[7.1]
  def change
    add_column :simulations, :currency, :string
  end
end
