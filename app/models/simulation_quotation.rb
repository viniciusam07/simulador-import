class SimulationQuotation < ApplicationRecord
  belongs_to :simulation
  belongs_to :quotation

  # Adiciona versionamento com PaperTrail
  has_paper_trail on: %i[create update destroy],
                  ignore: [:updated_at],
                  meta: { simulation_id: :simulation_id }

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
  before_save :set_default_tax_rates

  # Calcula o valor total da cotação na simulação (Quantidade * Preço Unitário)
  def total_value
    (custom_price || quotation&.price || 0) * quantity.to_f
  end

  def total_value_brl
    simulation.convert_to_brl(total_value, quotation.currency, simulation.exchange_rate_goods)
  end

  def freight_allocated_brl
    simulation.convert_to_brl(freight_allocated.to_f, simulation.currency_freight, simulation.exchange_rate_freight)
  end

  def insurance_allocated_brl
    simulation.convert_to_brl(insurance_allocated.to_f, simulation.currency_insurance, simulation.exchange_rate_insurance)
  end

  def unit_price_brl
    simulation.convert_to_brl(custom_price || quotation.price, quotation.currency, simulation.exchange_rate_goods)
  end

  def logistic_cost_per_unit
    total_quantity = simulation.simulation_quotations.sum(&:quantity)
    return 0 if total_quantity.zero?

    (simulation.freight_cost_brl.to_f + simulation.insurance_cost_brl.to_f) / total_quantity
  end

  def tax_cost_per_unit
    return 0 if quantity.zero?

    (tributo_ii.to_f + tributo_ipi.to_f + tributo_pis.to_f + tributo_cofins.to_f + tributo_icms.to_f) / quantity.to_f
  end

  def operational_cost_per_unit
    total_quantity = simulation.simulation_quotations.sum(&:quantity)
    return 0 if total_quantity.zero?

    total_operational_expenses = simulation.total_operational_expenses
    (total_operational_expenses.to_f / total_quantity).round(2)
  end

  def total_unit_inventory_cost
    unit_price_brl + logistic_cost_per_unit + tax_cost_per_unit + operational_cost_per_unit
  end

  def unit_import_factor
    return 0 if unit_price_brl.to_f.zero?

    total_costs_per_unit = unit_price_brl + logistic_cost_per_unit + tax_cost_per_unit + operational_cost_per_unit
    (total_costs_per_unit / unit_price_brl).round(2)
  end

  def customs_total_value_brl
    total_value_brl + freight_allocated_brl + insurance_allocated_brl
  end

  def customs_unit_value_brl
    return 0 if quantity.to_f.zero?
    customs_total_value_brl / quantity
  end

  private

  def set_default_custom_price
    self.custom_price ||= quotation&.price if quotation.present?
  end

  def calculate_allocations
    calculate_freight_allocation
    calculate_insurance_allocation
  end

  def calculate_freight_allocation
    total_weight = simulation.simulation_quotations.sum { |sq| sq.quotation.product.unit_net_weight.to_f * sq.quantity.to_f }
    self.freight_allocated = (simulation.freight_cost.to_f / total_weight) * (quotation.product.unit_net_weight.to_f * quantity.to_f)
  end

  def calculate_insurance_allocation
    total_custom_value = simulation.simulation_quotations.sum(&:total_value)
    self.insurance_allocated = (simulation.insurance_cost.to_f / total_custom_value) * total_value
  end

  def calculate_customs_values
    self.customs_unit_value = (total_value.to_f + freight_allocated.to_f + insurance_allocated.to_f) / (quantity.to_f.nonzero? || 1)
    self.customs_total_value = customs_unit_value * quantity.to_f
    simulation.convert_to_brl(customs_total_value, simulation.currency)
  end

  def calculate_tax_values
    customs_value = calculate_customs_values
    self.tributo_ii = calculate_ii(customs_value)
    self.tributo_ipi = calculate_ipi(customs_value, tributo_ii)
    self.tributo_pis = calculate_pis(customs_value)
    self.tributo_cofins = calculate_cofins(customs_value)
    self.tributo_icms = calculate_icms(customs_value, tributo_ii, tributo_ipi, tributo_pis, tributo_cofins)
  end

  def calculate_ii(customs_value)
    customs_value * ((aliquota_ii || 0) / 100.0)
  end

  def calculate_ipi(customs_value, ii_value)
    (customs_value + ii_value.to_f) * ((aliquota_ipi || 0) / 100.0)
  end

  def calculate_pis(customs_value)
    customs_value * ((aliquota_pis || 0) / 100.0)
  end

  def calculate_cofins(customs_value)
    customs_value * ((aliquota_cofins || 0) / 100.0)
  end

  def calculate_icms(customs_value, ii_value, ipi_value, pis_value, cofins_value)
    aliquota_icms_value = (aliquota_icms.presence || 0).to_f
    return 0 if aliquota_icms_value <= 0 || aliquota_icms_value >= 100

    base_icms = (customs_value + ii_value.to_f + ipi_value.to_f + pis_value.to_f + cofins_value.to_f) / (100 - aliquota_icms)
    base_icms * (aliquota_icms || 0)
  end

  def set_default_tax_rates
    self.aliquota_ii ||= 0
    self.aliquota_ipi ||= 0
    self.aliquota_pis ||= 0
    self.aliquota_cofins ||= 0
    self.aliquota_icms ||= 0
  end
end
