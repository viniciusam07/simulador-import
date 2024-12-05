class SimulationExpense < ApplicationRecord
  belongs_to :simulation
  belongs_to :expense, optional: true # Pode ser customizado
  validates :expense_custom_name, :expense_custom_value, presence: true, if: -> { expense_id.nil? }

  # Callback para preencher valores a partir de uma Expense
  before_validation :set_defaults_from_expense, if: -> { expense.present? }

  private

  def set_defaults_from_expense
    self.expense_custom_name ||= expense.expense_name
    self.expense_custom_value ||= expense.expense_default_value
    self.expense_currency ||= expense.expense_currency
    self.expense_location ||= expense.expense_location
  end

end
