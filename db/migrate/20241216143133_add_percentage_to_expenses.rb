class AddPercentageToExpenses < ActiveRecord::Migration[7.1]
  def change
    add_column :expenses, :percentage, :decimal
  end
end
