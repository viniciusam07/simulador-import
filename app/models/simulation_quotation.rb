class SimulationQuotation < ApplicationRecord
  belongs_to :simulation
  belongs_to :quotation

  # Adiciona versionamento com PaperTrail
  has_paper_trail on: %i[create update destroy], # Acompanha todas as alterações
                  ignore: [:updated_at],        # Ignora atualizações irrelevantes
                  meta: { simulation_id: :simulation_id } # Adiciona metadados relevantes

  # Validações
  validates :quotation_id, uniqueness: { scope: :simulation_id, message: "já está adicionada à simulação" }, on: :create
  validates :quantity, numericality: { greater_than_or_equal_to: 0 }
  validates :custom_price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :aliquota_ii, :aliquota_ipi, :aliquota_pis, :aliquota_cofins, :aliquota_icms,
            numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_nil: true
  validates :total_value, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  # Callbacks
  before_save :set_default_custom_price
  before_save :calculate_tax_values
  before_save :calculate_allocations
  before_save :calculate_customs_values

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

  # Calcula as alocações de frete e seguro
  def calculate_allocations
    calculate_freight_allocation
    calculate_insurance_allocation
  end

  # Aloca o frete com base no peso líquido
  def calculate_freight_allocation
    total_weight = simulation.simulation_quotations.sum { |sq| sq.quotation.product.unit_net_weight.to_f * sq.quantity.to_f }
    self.freight_allocated = (simulation.freight_cost.to_f / total_weight) * (quotation.product.unit_net_weight.to_f * quantity.to_f)
  end

  # Aloca o seguro com base no valor aduaneiro
  def calculate_insurance_allocation
    total_custom_value = simulation.simulation_quotations.sum(&:total_value)
    self.insurance_allocated = (simulation.insurance_cost.to_f / total_custom_value) * total_value
  end

  # Calcula os valores aduaneiros (unitário e total)

  def calculate_customs_values
    self.customs_unit_value = (total_value.to_f + freight_allocated.to_f + insurance_allocated.to_f) / (quantity.to_f.nonzero? || 1)
    self.customs_total_value = customs_unit_value * quantity.to_f
  end
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
