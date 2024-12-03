class Simulation < ApplicationRecord
  validates :origin_country, presence: true
  validates :total_value, presence: true, numericality: { greater_than: 0 }
  validates :incoterm, presence: true
  validates :modal, presence: true

  before_save :set_customs_value

  def calculate_customs_value
    # Valor Aduaneiro = Produtos + Frete + Seguro
    total_value + freight_cost.to_f + insurance_cost.to_f
  end

  private

  def set_customs_value
    self.customs_value = calculate_customs_value
  end

end
