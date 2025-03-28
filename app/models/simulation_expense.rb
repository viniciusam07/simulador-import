class SimulationExpense < ApplicationRecord
  belongs_to :simulation
  belongs_to :expense, optional: true

  enum tax_calculation_impact: {
    no_impact: 0,
    icms: 1,
    customs_value: 2,
    all_taxes: 3
  }

  before_validation :set_defaults_from_expense, if: -> { expense.present? }
  before_save :recalculate_custom_value, if: -> { expense.present? }

  def recalculate_custom_value
    self.expense_custom_value = calculate_custom_value
  end

  def calculate_custom_value
    # Despesa fixa: converte para BRL a partir da moeda original
    unless expense.percentage.present?
      return simulation.convert_to_brl(expense.expense_default_value.to_f, expense.expense_currency)
    end

    # Base de cálculo para percentual
    base_value = calculate_base_value(expense.calculation_base)

    return 0 unless base_value.to_f.positive?

    (base_value * (expense.percentage / 100.0)).round(2)
  end

  private

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

  def set_defaults_from_expense
    self.expense_custom_name ||= expense.expense_name
    self.expense_custom_value = calculate_custom_value
    self.expense_currency ||= expense.expense_currency
    self.expense_location ||= expense.expense_location
    self.tax_calculation_impact ||= expense.tax_calculation_impact
  end
end
