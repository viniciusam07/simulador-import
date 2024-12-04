class SimulationTax < ApplicationRecord
  belongs_to :simulation
  belongs_to :tax
  validates :calculated_value, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
