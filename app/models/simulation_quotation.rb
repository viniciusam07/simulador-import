class SimulationQuotation < ApplicationRecord
  belongs_to :simulation
  belongs_to :quotation

  validates :quotation_id, uniqueness: { scope: :simulation_id, message: "já está adicionada à simulação" }
end
