class Product < ApplicationRecord
  UNIT_OF_MEASURE_OPTIONS = [
    ['Grama', 'G'],
    ['Jogo', 'JOGO'],
    ['Litro', 'LT'],
    ['Megawatt hora', 'MWHORA'],
    ['Metro', 'METRO'],
    ['Metro cúbico', 'M3'],
    ['Metro quadrado', 'M2'],
    ['Mil unidades', '1000UN'],
    ['Pares', 'PARES'],
    ['Quilate', 'QUILAT'],
    ['Quilograma', 'KG'],
    ['Unidade', 'UN']
  ].freeze
  has_many :quotations, dependent: :destroy
  # Validações para garantir que os campos principais estejam sempre presentes
  validates :product_name, :unit_of_measure, :unit_price, :ncm, presence: true
  validates :unit_price, numericality: { greater_than_or_equal_to: 0 }
  validates :unit_net_weight, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :quantity_per_box, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
end
