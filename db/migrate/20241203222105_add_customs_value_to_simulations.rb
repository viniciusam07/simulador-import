class AddCustomsValueToSimulations < ActiveRecord::Migration[7.1]
  def change
    add_column :simulations, :customs_value, :decimal
  end
end
