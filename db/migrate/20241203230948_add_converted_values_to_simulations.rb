class AddConvertedValuesToSimulations < ActiveRecord::Migration[7.1]
  def change
    add_column :simulations, :total_customs_value_brl, :decimal
  end
end
