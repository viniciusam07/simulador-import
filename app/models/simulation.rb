class Simulation < ApplicationRecord
  has_many :simulation_expenses, dependent: :destroy
  has_many :expenses, through: :simulation_expenses
  has_many :simulation_quotations, dependent: :destroy
  has_many :quotations, through: :simulation_quotations

  accepts_nested_attributes_for :simulation_quotations, allow_destroy: true

  # Validações
  validates :origin_country, presence: true
  validates :total_value, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :incoterm, presence: true
  validates :modal, presence: true
  validates :currency, presence: true
  validates :freight_cost, :insurance_cost, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  # Callbacks
  before_save :calculate_total_value
  before_save :set_customs_value
  before_save :set_total_customs_value_brl
  before_save :set_converted_values
  before_save :calculate_taxes

  # Métodos públicos

  # Calcula o valor total da simulação com base nas cotações
  def calculate_total_value
    self.total_value = simulation_quotations.sum(&:total_value)
  end

  # Valor aduaneiro = Produtos + Frete + Seguro em moeda estrangeira
  def calculate_customs_value
    total_value.to_f + freight_cost.to_f + insurance_cost.to_f
  end

  # Valor aduaneiro em BRL = Produtos + Frete + Seguro convertidos para BRL
  def calculate_customs_value_brl
    convert_to_brl(total_value, currency) +
      convert_to_brl(freight_cost, currency) +
      convert_to_brl(insurance_cost, currency)
  end

  # Consolida os valores de impostos calculados por cotação
  def calculate_taxes
    self.tributo_ii = simulation_quotations.sum(:tributo_ii)
    self.tributo_ipi = simulation_quotations.sum(:tributo_ipi)
    self.tributo_pis = simulation_quotations.sum(:tributo_pis)
    self.tributo_cofins = simulation_quotations.sum(:tributo_cofins)
    self.tributo_icms = simulation_quotations.sum(:tributo_icms)
  end

  # Total de despesas operacionais
  def total_operational_expenses
    simulation_expenses.sum(:expense_custom_value)
  end

  # Total de impostos
  def total_taxes
    tributo_ii.to_f +
      tributo_ipi.to_f +
      tributo_pis.to_f +
      tributo_cofins.to_f +
      tributo_icms.to_f
  end

  # Valor total da importação
  def total_importation_cost
    total_customs_value_brl.to_f + total_taxes + total_operational_expenses
  end

  # Conversão para BRL com base na taxa de câmbio
  def convert_to_brl(amount, currency)
    return 0 if amount.blank? || currency.blank?
    return amount if currency == 'BRL'

    exchange_rate_value = exchange_rate.presence || fetch_exchange_rate(currency)
    amount.to_f * exchange_rate_value.to_f
  end

  private

  # Define o valor aduaneiro
  def set_customs_value
    self.customs_value = calculate_customs_value
  end

  # Define o valor aduaneiro em BRL
  def set_total_customs_value_brl
    self.total_customs_value_brl = calculate_customs_value_brl
  end

  # Calcula e seta valores convertidos para BRL
  def set_converted_values
    self.freight_cost_brl = convert_to_brl(freight_cost, currency)
    self.insurance_cost_brl = convert_to_brl(insurance_cost, currency)
    self.total_value_brl = convert_to_brl(total_value, currency)
  end

  # Busca a taxa de câmbio atual para conversão
  def fetch_exchange_rate(currency)
    bank = EuCentralBank.new
    bank.update_rates
    Money.default_bank = bank
    Money.new(100, currency).exchange_to('BRL').to_f
  end
end
