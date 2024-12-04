class TaxRate < ApplicationRecord
  belongs_to :tax
  validates :ncm, presence: true
  validates :rate, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
