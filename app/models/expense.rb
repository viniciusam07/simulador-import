class Expense < ApplicationRecord
  has_many :simulation_expenses
  validates :expense_name, :expense_currency, :expense_default_value, :expense_location, presence: true
end
