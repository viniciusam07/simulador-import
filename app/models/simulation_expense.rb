class SimulationExpense < ApplicationRecord
  belongs_to :simulation
  belongs_to :expense, optional: true

  before_validation :set_defaults_from_expense, if: -> { expense.present? }

  def calculate_percentage_value(base_value)
    expense.percentage ? (base_value * expense.percentage / 100.0) : expense.expense_default_value
  end

  private

  def set_defaults_from_expense
    self.expense_custom_name ||= expense.expense_name
    self.expense_custom_value ||= calculate_percentage_value(simulation.freight_cost) if expense.percentage
    self.expense_currency ||= expense.expense_currency
    self.expense_location ||= expense.expense_location
  end
end
