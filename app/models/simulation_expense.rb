class SimulationExpense < ApplicationRecord
  belongs_to :simulation
  belongs_to :expense, optional: true

  enum tax_calculation_impact: {
    no_impact: 0,
    icms: 1,
    customs_value: 2,
    all_taxes: 3
  }

  # Callbacks
  before_validation :set_defaults_from_expense, if: -> { expense.present? }
  before_save :recalculate_custom_value, if: -> { expense.present? }

  # Recalcula o valor customizado da despesa em BRL
  def recalculate_custom_value
    self.expense_custom_value = calculate_custom_value
  end

  # Calcula o valor da despesa em BRL, levando em conta se é percentual ou valor fixo
  def calculate_custom_value
    # Despesa fixa: converte para BRL com a cotação apropriada
    unless expense.percentage.present?
      exchange_rate = case expense.calculation_base
                      when 'freight_cost'   then simulation.exchange_rate_freight
                      when 'insurance_cost' then simulation.exchange_rate_insurance
                      when 'total_value', 'customs_value' then simulation.exchange_rate_goods
                      else
                        simulation.exchange_rate_goods # fallback padrão
                      end

      return simulation.convert_to_brl(expense.expense_default_value.to_f, expense.expense_currency, exchange_rate)
    end

    # Despesa percentual: calcula sobre a base convertida
    base_value = calculate_base_value(expense.calculation_base)
    return 0 unless base_value.to_f.positive?

    (base_value * (expense.percentage / 100.0)).round(2)
  end

  # Retorna o valor original da despesa (sem conversão), útil para exibição
  def value_in_original_currency
    return nil unless expense.present?

    if expense.type_of_expense == 'fixed' && expense.expense_default_value.present?
      return expense.expense_default_value
    end

    base = case expense.calculation_base
           when 'freight_cost'   then simulation.freight_cost
           when 'insurance_cost' then simulation.insurance_cost
           when 'total_value'    then simulation.total_value
           when 'customs_value'  then simulation.calculate_customs_value
           else 0
           end

    return 0 unless base.to_f.positive? && expense.percentage.present?

    (base.to_f * (expense.percentage.to_f / 100.0)).round(2)
  end

  private

  # Retorna a base de cálculo convertida para BRL, usada em despesas percentuais
  def calculate_base_value(calculation_base)
    case calculation_base
    when 'freight_cost'
      simulation.freight_cost_brl.presence || simulation.convert_to_brl(simulation.freight_cost, simulation.currency_freight, simulation.exchange_rate_freight)
    when 'insurance_cost'
      simulation.insurance_cost_brl.presence || simulation.convert_to_brl(simulation.insurance_cost, simulation.currency_insurance, simulation.exchange_rate_insurance)
    when 'total_value'
      simulation.total_value_brl.presence || simulation.convert_to_brl(simulation.total_value, simulation.currency, simulation.exchange_rate_goods)
    when 'customs_value'
      simulation.total_customs_value_brl.presence || simulation.calculate_customs_value_brl
    else
      0
    end
  end

  # Define valores padrão com base no Expense associado
  def set_defaults_from_expense
    self.expense_custom_name ||= expense.expense_name
    self.expense_custom_value = calculate_custom_value
    self.expense_currency ||= expense.expense_currency
    self.expense_location ||= expense.expense_location
    self.tax_calculation_impact ||= expense.tax_calculation_impact
  end
end
