class Step < ApplicationRecord
  validates :name, presence: true
  validates :location, presence: true
  validates :default_sla, numericality: { greater_than_or_equal_to: 0 }
end
