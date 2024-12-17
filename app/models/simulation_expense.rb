class SimulationExpense < ApplicationRecord
  belongs_to :simulation
  belongs_to :expense, optional: true

  before_validation :set_defaults_from_expense, if: -> { expense.present? }

  def calculate_custom_value
    return expense.expense_default_value if expense.percentage.blank?

    base_value = case expense.calculation_base
                 when 'freight_cost'
                   simulation&.freight_cost.to_f
                 when 'customs_value'
                   simulation&.customs_value.to_f
                 when 'total_value'
                   simulation&.total_value.to_f
                 else
                   0
                 end
    base_value * (expense.percentage / 100.0)
  end

  private

  def set_defaults_from_expense
    self.expense_custom_name ||= expense.expense_name
    self.expense_custom_value ||= calculate_custom_value
    self.expense_currency ||= expense.expense_currency
    self.expense_location ||= expense.expense_location
  end
end
