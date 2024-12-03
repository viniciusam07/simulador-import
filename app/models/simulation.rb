class Simulation < ApplicationRecord
  validates :origin_country, presence: true
  validates :total_value, presence: true, numericality: { greater_than: 0 }
  validates :incoterm, presence: true
  validates :modal, presence: true
end
