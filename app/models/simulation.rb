class Simulation < ApplicationRecord
  has_many :simulation_expenses, dependent: :destroy
  has_many :expenses, through: :simulation_expenses

  validates :origin_country, presence: true
  validates :total_value, presence: true, numericality: { greater_than: 0 }
  validates :incoterm, presence: true
  validates :modal, presence: true
  validates :currency, presence: true
  validates :aliquota_ii, :aliquota_ipi, :aliquota_pis, :aliquota_cofins, :aliquota_icms,
            numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }

  before_save :set_customs_value, :set_total_customs_value_brl, :calculate_taxes, :set_converted_values

  def calculate_customs_value
    # Valor Aduaneiro = Produtos + Frete + Seguro em moeda estrangeira
    total_value.to_f + freight_cost.to_f + insurance_cost.to_f
  end

  def calculate_customs_value_brl
    # Valor Aduaneiro em BRL = Produtos + Frete + Seguro convertidos para BRL
    convert_to_brl(total_value, currency) + convert_to_brl(freight_cost, currency) + convert_to_brl(insurance_cost, currency)
  end

  def convert_to_brl(amount, currency)
    return 0 if amount.blank? || currency.blank? # Evita erros para valores nulos ou moedas ausentes
    return amount if currency == 'BRL'

    bank = EuCentralBank.new
    bank.update_rates
    Money.default_bank = bank
    money = Money.new(amount * 100, currency) # Money gem works with cents
    money.exchange_to('BRL').to_f
  end

  def customs_value_brl
    # Certifique-se de que o valor aduaneiro em BRL está calculado
    self.total_customs_value_brl ||= calculate_customs_value_brl
  end

  # Calcula o Imposto de Importação (II)
  def aliquotas_ii(ii_rate)
    # Valor CIF * II%
    customs_value_brl * ((ii_rate || 0) / 100.0)
  end

  # Calcula o Imposto sobre Produtos Industrializados (IPI)
  def aliquotas_ipi(ii_value, ipi_rate)
    # (Valor CIF + II) * IPI%
    (customs_value_brl + (ii_value || 0)) * ((ipi_rate || 0) / 100.0)
  end

  # Calcula o PIS-Importação
  def aliquotas_pis(pis_rate)
    # Valor CIF * PIS%
    customs_value_brl * ((pis_rate || 0) / 100.0)
  end

  # Calcula o Cofins-Importação
  def aliquotas_cofins(cofins_rate)
    # Valor CIF * COFINS%
    customs_value_brl * ((cofins_rate || 0) / 100.0)
  end

  # Calcula o ICMS
  def aliquotas_icms(ii_value, ipi_value, pis_value, cofins_value, icms_base, icms_reduction, icms_rate)
    # Base de cálculo do ICMS
    base_icms = customs_value_brl + ii_value + ipi_value + pis_value + cofins_value - icms_reduction
    # ICMS
    base_icms * ((icms_rate || 0) / 100.0)
  end

  def total_operational_expenses
    simulation_expenses.sum(:expense_custom_value)
  end

  def total_taxes
    tributo_ii + tributo_ipi + tributo_pis + tributo_cofins + tributo_icms
  end

  def total_importation_cost
    customs_value_brl + total_taxes + total_operational_expenses
  end

  # Calcula o valor total de impostos
  def total_taxes
    (tributo_ii || 0) +
    (tributo_ipi || 0) +
    (tributo_pis || 0) +
    (tributo_cofins || 0) +
    (tributo_icms || 0)
  end

  private
  # Seta os valores convertidos em BRL antes de salvar
  def set_converted_values
    self.freight_cost_brl = convert_to_brl(freight_cost, currency)
    self.insurance_cost_brl = convert_to_brl(insurance_cost, currency)
    self.total_value_brl = convert_to_brl(total_value, currency)
  end
  def set_customs_value
    self.customs_value = calculate_customs_value
  end
  def set_total_customs_value_brl
    self.total_customs_value_brl = calculate_customs_value_brl
  end

  def calculate_taxes
    self.tributo_ii = aliquotas_ii(aliquota_ii)
    self.tributo_ipi = aliquotas_ipi(tributo_ii, aliquota_ipi)
    self.tributo_pis = aliquotas_pis(aliquota_pis)
    self.tributo_cofins = aliquotas_cofins(aliquota_cofins)
    self.tributo_icms = aliquotas_icms(tributo_ii, tributo_ipi, tributo_pis, tributo_cofins, 0, 0, aliquota_icms)
  end
end
