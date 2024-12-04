class Tax < ApplicationRecord
  has_many :tax_rates
  has_many :simulation_taxes
end
