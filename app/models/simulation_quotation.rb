class SimulationQuotation < ApplicationRecord
  belongs_to :simulation
  belongs_to :quotation

  # Validações
  validates :quotation_id, uniqueness: { scope: :simulation_id, message: "já está adicionada à simulação" }
  validates :quantity, numericality: { greater_than_or_equal_to: 0 }
  validates :custom_price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :aliquota_ii, :aliquota_ipi, :aliquota_pis, :aliquota_cofins, :aliquota_icms,
            numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_nil: true

  # Callbacks
  before_save :set_default_custom_price
  before_save :calculate_tax_values

  # Métodos públicos

  # Calcula o valor total da cotação na simulação (Quantidade * Preço Unitário)
  def total_value
    (custom_price || quotation&.price || 0) * quantity.to_f
  end

  # Calcula os valores de impostos para esta cotação
  def calculate_tax_values
    # Valor aduaneiro: soma do valor total dos produtos, custo de frete e custo de seguro
    customs_value = total_value.to_f + (simulation.freight_cost || 0) + (simulation.insurance_cost || 0)

    # Calcular os valores de cada imposto individualmente
    self.tributo_ii = calculate_ii(customs_value)                      # Imposto de Importação
    self.tributo_ipi = calculate_ipi(customs_value, tributo_ii)        # Imposto sobre Produtos Industrializados
    self.tributo_pis = calculate_pis(customs_value)                    # PIS-Importação
    self.tributo_cofins = calculate_cofins(customs_value)              # Cofins-Importação
    self.tributo_icms = calculate_icms(customs_value, tributo_ii, tributo_ipi, tributo_pis, tributo_cofins) # ICMS
  end

  private

  # Define o preço customizado padrão como o preço da cotação, caso não esteja definido
  def set_default_custom_price
    self.custom_price ||= quotation&.price if quotation.present?
  end

  # Cálculo de Impostos

  # Imposto de Importação (II)
  # Fórmula: Valor Aduaneiro (CIF) * Alíquota II
  def calculate_ii(customs_value)
    customs_value * ((aliquota_ii || 0) / 100.0)
  end

  # Imposto sobre Produtos Industrializados (IPI)
  # Fórmula: (Valor Aduaneiro (CIF) + Imposto de Importação) * Alíquota IPI
  def calculate_ipi(customs_value, ii_value)
    (customs_value + ii_value.to_f) * ((aliquota_ipi || 0) / 100.0)
  end

  # PIS-Importação
  # Fórmula: Valor Aduaneiro (CIF) * Alíquota PIS
  def calculate_pis(customs_value)
    customs_value * ((aliquota_pis || 0) / 100.0)
  end

  # Cofins-Importação
  # Fórmula: Valor Aduaneiro (CIF) * Alíquota Cofins
  def calculate_cofins(customs_value)
    customs_value * ((aliquota_cofins || 0) / 100.0)
  end

  # ICMS
  # Fórmula: (Base ICMS) * Alíquota ICMS
  # Base ICMS: Valor Aduaneiro (CIF) + II + IPI + PIS + Cofins
  def calculate_icms(customs_value, ii_value, ipi_value, pis_value, cofins_value)
    base_icms = customs_value + ii_value.to_f + ipi_value.to_f + pis_value.to_f + cofins_value.to_f
    base_icms * ((aliquota_icms || 0) / 100.0)
  end
end
