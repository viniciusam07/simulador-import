module ExpensesHelper
  def human_tax_impact(value)
    case value
    when "none"
      "Sem impacto"
    when "icms"
      "ICMS"
    when "customs_value"
      "Valor Aduaneiro"
    when "all"
      "ICMS e Valor Aduaneiro"
    else
      "-"
    end
  end
end
