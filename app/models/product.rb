class Product < ApplicationRecord
  # Validações para garantir que os campos principais estejam sempre presentes
  validates :product_name, :unit_of_measure, :unit_price, presence: true
  validates :unit_price, numericality: { greater_than_or_equal_to: 0 }
  validates :unit_net_weight, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :quantity_per_box, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
end

