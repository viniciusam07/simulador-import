class AddFreightAndInsuranceToSimulations < ActiveRecord::Migration[7.1]
  def change
    add_column :simulations, :freight_cost, :decimal
    add_column :simulations, :insurance_cost, :decimal
  end
end
