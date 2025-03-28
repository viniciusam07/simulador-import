class AddTaxCalculationImpactToExpenses < ActiveRecord::Migration[7.1]
  def change
    add_column :expenses, :tax_calculation_impact, :integer, default: 0, null: false
  end
end
