class SimulationQuotation < ApplicationRecord
  belongs_to :simulation
  belongs_to :quotation

  validates :quotation_id, uniqueness: { scope: :simulation_id, message: "já está adicionada à simulação" }
  validates :total_value, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  before_save :calculate_total_value

  private

  def calculate_total_value
    self.total_value ||= quotation.price * quantity if quotation && quantity
  end
end
