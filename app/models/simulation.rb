class Simulation < ApplicationRecord
  validates :origin_country, presence: true
  validates :total_value, presence: true, numericality: { greater_than: 0 }
  validates :incoterm, presence: true
  validates :modal, presence: true
  validates :currency, presence: true

  before_save :set_customs_value, :set_total_customs_value_brl

  def calculate_customs_value
    # Valor Aduaneiro = Produtos + Frete + Seguro em moeda estrangeira
    total_value.to_f + freight_cost.to_f + insurance_cost.to_f
  end

  def calculate_customs_value_brl
    # Valor Aduaneiro em BRL = Produtos + Frete + Seguro convertidos para BRL
    convert_to_brl(total_value, currency) + convert_to_brl(freight_cost, currency) + convert_to_brl(insurance_cost, currency)
  end

  def convert_to_brl(amount, currency)
    bank = EuCentralBank.new
    bank.update_rates
    Money.default_bank = bank
    money = Money.new(amount * 100, currency) # Money gem works with cents
    money.exchange_to('BRL').to_f
  end

  private

  def set_customs_value
    self.customs_value = calculate_customs_value
  end

  def set_total_customs_value_brl
    self.total_customs_value_brl = calculate_customs_value_brl
  end

end
