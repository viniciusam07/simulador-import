class AddImportFactorToSimulations < ActiveRecord::Migration[7.1]
  def change
    add_column :simulations, :import_factor, :decimal, precision: 10, scale: 2
  end
end
