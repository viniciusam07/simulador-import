class Simulation < ApplicationRecord
  has_paper_trail(
    versions: { class_name: 'SimulationVersion' }, # Nome personalizado para a associação
    on: %i[create update destroy],                # Eventos que criam versões
    ignore: [:updated_at],                        # Ignorar atributos que não criam versões
    meta: { user_id: :user_id, simulation_id: :id }                   # Salvar informações extras
  )
  # Carrega os estados brasileiros do arquivo YAML
  BRAZILIAN_STATES = [
    ['Acre', 'AC'], ['Alagoas', 'AL'], ['Amapá', 'AP'], ['Amazonas', 'AM'],
    ['Bahia', 'BA'], ['Ceará', 'CE'], ['Distrito Federal', 'DF'], ['Espírito Santo', 'ES'],
    ['Goiás', 'GO'], ['Maranhão', 'MA'], ['Mato Grosso', 'MT'], ['Mato Grosso do Sul', 'MS'],
    ['Minas Gerais', 'MG'], ['Pará', 'PA'], ['Paraíba', 'PB'], ['Paraná', 'PR'],
    ['Pernambuco', 'PE'], ['Piauí', 'PI'], ['Rio de Janeiro', 'RJ'], ['Rio Grande do Norte', 'RN'],
    ['Rio Grande do Sul', 'RS'], ['Rondônia', 'RO'], ['Roraima', 'RR'],
    ['Santa Catarina', 'SC'], ['São Paulo', 'SP'], ['Sergipe', 'SE'], ['Tocantins', 'TO']
  ].freeze

  CFOPS = {
    "3101" => "Compra para industrialização",
    "3102" => "Compra para comercialização",
    "3949" => "Outras entradas",
    "5160" => "Fornecimento de mercadorias adquiridas ou recebidas",
    "3126" => "Compra para prestação de serviço sujeita ao ICMS"
  }.freeze

  belongs_to :equipment, optional: true
  belongs_to :company, optional: true
  belongs_to :user

  has_many :simulation_expenses, dependent: :destroy
  has_many :expenses, through: :simulation_expenses
  has_many :simulation_quotations, dependent: :destroy
  has_many :quotations, through: :simulation_quotations
  has_one :simulation_schedule, dependent: :destroy


  accepts_nested_attributes_for :simulation_quotations, allow_destroy: true

  # Validações
  validates :origin_country, presence: true
  validates :total_value, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :incoterm, presence: true
  validates :modal, presence: true
  validates :currency, presence: true
  validates :freight_cost, :insurance_cost, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :destination_state, presence: true, inclusion: { in: BRAZILIAN_STATES.map { |state| state[1] } }
  validates :origin_port, :destination_port, presence: true, if: -> { modal == 'Marítimo' }
  validates :origin_airport, :destination_airport, presence: true, if: -> { modal == 'Aéreo' }
  validates :cfop_code, presence: true, inclusion: { in: CFOPS.keys.map(&:to_s), message: "inválido" }
  validates :cfop_description, presence: true
  validates :equipment_id, :equipment_quantity, presence: true, if: -> { modal == 'Marítimo' }
  validates :cbm_total, :weight_net_total, :weight_gross_total, numericality: { greater_than_or_equal_to: 0 }
  validates :cargo_type, inclusion: { in: ['FCL', 'LCL'], message: 'Tipo de carga inválido' }, if: :maritime_modal?


  # Callbacks
  before_validation :set_default_tax_rates
  before_save :set_cfop_description
  before_save :calculate_total_value
  before_save :set_customs_value
  before_save :set_total_customs_value_brl
  before_save :set_converted_values
  before_save :calculate_taxes
  before_save :calculate_import_factor

  # Métodos públicos

  # Calcula o valor total da simulação com base nas cotações
  def calculate_total_value
    self.total_value = simulation_quotations.sum(&:total_value)
  end

  # Calcula o valor aduaneiro total com base nas cotações
  def calculate_customs_value
    simulation_quotations.sum { |sq| sq.customs_total_value.to_f }
  end

  # Valor aduaneiro em BRL
  # Converte o valor total aduaneiro e despesas para BRL
  def calculate_customs_value_brl
    customs_value_total = calculate_customs_value
    convert_to_brl(customs_value_total, currency)
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
    customs_value_brl = calculate_customs_value_brl
    customs_value_brl + total_taxes + total_operational_expenses
  end

  # Rateio das despesas operacionais proporcional à quantidade de produtos
  def operational_expense_allocation
    total_quantity = simulation_quotations.sum(&:quantity)
    return [] if total_quantity.zero?

    simulation_quotations.includes(:quotation).map do |sq|
      allocated_expense = (total_operational_expenses.to_f / total_quantity * sq.quantity).round(2)
      {
        product_name: sq.quotation.product.product_name,
        supplier_name: sq.quotation.supplier.trade_name,
        quantity: sq.quantity,
        allocated_expense: allocated_expense,
        unit_expense: (allocated_expense / sq.quantity.to_f).round(2) # Valor unitário
      }
    end
  end

  # Total de despesas operacionais
  def total_operational_expenses
    simulation_expenses.sum(:expense_custom_value)
  end

  # Total de despesas operacionais
  def total_operational_expenses
    simulation_expenses.sum(:expense_custom_value)
  end

  # Conversão para BRL com base na taxa de câmbio
  def convert_to_brl(amount, currency)
    return 0 if amount.blank? || currency.blank?
    return amount if currency == 'BRL'

    exchange_rate_value = exchange_rate.presence || fetch_exchange_rate(currency)
    amount.to_f * exchange_rate_value.to_f
  end

  # Resumo de custos unitários
  def unit_cost_summary
    simulation_quotations.includes(:quotation).map do |sq|
      {
        product_name: sq.quotation.product.product_name,
        supplier_name: sq.quotation.supplier.trade_name,
        quantity: sq.quantity,
        unit_price_brl: sq.unit_price_brl.round(2),
        logistic_cost_per_unit: sq.logistic_cost_per_unit.round(2),
        tax_cost_per_unit: sq.tax_cost_per_unit.round(2),
        operational_cost_per_unit: sq.operational_cost_per_unit.round(2),
        total_unit_inventory_cost: sq.total_unit_inventory_cost.round(2),
        allocated_expense: sq.operational_cost_per_unit.round(2), # Apenas para alinhamento
        unit_expense: (sq.operational_cost_per_unit / sq.quantity.to_f).round(2),
        unit_import_factor: sq.unit_import_factor.round(2)
      }
    end
  end

  private

  # Define valores padrão para alíquotas se estiverem nil
  def set_default_tax_rates
    self.aliquota_ii ||= 0
    self.aliquota_ipi ||= 0
    self.aliquota_pis ||= 0
    self.aliquota_cofins ||= 0
    self.aliquota_icms ||= 0
  end

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

  # Calcula o Fator de Importação
  def calculate_import_factor
    return if total_importation_cost.to_f.zero?

    self.import_factor = (total_importation_cost.to_f / total_value_brl.to_f).round(2)
  end

  def set_cfop_description
    selected_cfop = CFOPS.find { |code, _| code == cfop_code }
    self.cfop_description = selected_cfop ? selected_cfop[1] : nil
  end

  def maritime_modal?
    Rails.logger.debug "Modal atual: #{modal}"
    modal == 'Marítimo'
  end
end
