class AddTypeOfExpenseAndCalculationBaseToExpenses < ActiveRecord::Migration[7.1]
  def change
    unless column_exists?(:expenses, :type_of_expense)
      add_column :expenses, :type_of_expense, :string
    end

    unless column_exists?(:expenses, :calculation_base)
      add_column :expenses, :calculation_base, :string
    end
  end
end
