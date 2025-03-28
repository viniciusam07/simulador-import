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
    # Para despesas de valor fixo, converte o valor padrão para BRL
    unless expense.percentage.present?
      return simulation.convert_to_brl(expense.expense_default_value.to_f, expense.expense_currency)
    end

    # Define a base de cálculo para despesas percentuais
    base_value = calculate_base_value(expense.calculation_base)

    # Retorna 0 se a base de cálculo for inválida ou não definida
    return 0 unless base_value.to_f.positive?

    # Calcula o valor percentual com base na base de cálculo e arredonda
    (base_value * (expense.percentage / 100.0)).round(2)
  end

  private

  def calculate_base_value(calculation_base)
    case calculation_base
    when 'freight_cost'
      simulation.freight_cost_brl || simulation.convert_to_brl(simulation.freight_cost, simulation.currency)
    when 'insurance_cost'
      simulation.insurance_cost_brl || simulation.convert_to_brl(simulation.insurance_cost, simulation.currency)
    when 'total_value'
      simulation.total_value_brl || simulation.convert_to_brl(simulation.total_value, simulation.currency)
    when 'customs_value'
      simulation.total_customs_value_brl || simulation.convert_to_brl(simulation.customs_value, simulation.currency)
    else
      0 # Retorna 0 se a base de cálculo não for reconhecida
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
