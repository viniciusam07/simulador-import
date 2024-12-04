class SimulationExpense < ApplicationRecord
  belongs_to :simulation
  belongs_to :expense, optional: true # Pode ser customizado
  validates :expense_custom_name, :expense_custom_value, presence: true, if: -> { expense_id.nil? }
end
