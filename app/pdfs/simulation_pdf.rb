class SimulationPdf < Prawn::Document
  def initialize(simulation, view)
    super(
      page_size: "A4",
      margin: [30, 30, 30, 30],
      info: {
        Title: "Simulação de Importação ##{simulation.id}",
        Author: simulation.user.email,
        Creator: "Mazzu Import",
        CreationDate: Time.current
      }
    )
    @simulation = simulation
    @view = view
    generate
  end

  private

  def generate
    header
    move_down 10
    general_details
    move_down 15
    logistics_details
    move_down 15
    quotations_details
    move_down 15
    taxes_and_expenses
    move_down 15
    summary
    footer
  end

  def header
    image "#{Rails.root}/app/assets/images/mazzu_logo_alta.png", width: 120, position: :left
    move_down 10
    text "Simulação de Importação ##{@simulation.id}", size: 16, style: :bold, align: :center
    move_down 5
    text "Empresa: #{@simulation.company&.name} | Criado em: #{@simulation.created_at.strftime('%d/%m/%Y')}", size: 10, align: :center
  end

  def general_details
    text "Detalhes Gerais", size: 12, style: :bold

    pad(10) do
      table(general_data, width: bounds.width) do |t|
        t.cells.borders = []
        t.cells.padding = [2, 5]
        t.columns(0).font_style = :bold
        t.columns(0).width = 150
      end
    end

    draw_progress_bar("Composição dos Custos Gerais", {
      "Produtos" => @simulation.total_value,
      "Frete" => @simulation.freight_cost,
      "Seguro" => @simulation.insurance_cost
    })
  end

  def general_data
    [
      ["Empresa:", @simulation.company&.name.to_s],
      ["CNPJ:", @simulation.company&.cnpj.to_s],
      ["País de Origem:", @simulation.origin_country.to_s],
      ["Incoterm:", @simulation.incoterm.to_s],
      ["Modal:", @simulation.modal.to_s],
      ["Moeda:", @simulation.currency.to_s],
      ["Taxa de Câmbio:", @simulation.exchange_rate.to_s],
      ["CFOP:", "#{@simulation.cfop_code} - #{@simulation.cfop_description}"],
      ["Valor Total:", @view.number_to_currency(@simulation.total_value.to_f, unit: @simulation.currency)],
      ["Valor Total (BRL):", @view.number_to_currency(@simulation.total_value_brl.to_f, unit: 'BRL')],
      ["Valor Aduaneiro:", @view.number_to_currency(@simulation.customs_value.to_f, unit: @simulation.currency)],
      ["Valor Aduaneiro (BRL):", @view.number_to_currency(@simulation.total_customs_value_brl.to_f, unit: 'BRL')]
    ]
  end

  def logistics_details
    text "Dados Logísticos", size: 12, style: :bold

    logistics_data = [
      ["Estado de Destino:", @simulation.destination_state.to_s],
      ["Frete:", @view.number_to_currency(@simulation.freight_cost.to_f, unit: @simulation.currency)],
      ["Frete (BRL):", @view.number_to_currency(@simulation.freight_cost_brl.to_f, unit: 'BRL')],
      ["Seguro:", @view.number_to_currency(@simulation.insurance_cost.to_f, unit: @simulation.currency)],
      ["Seguro (BRL):", @view.number_to_currency(@simulation.insurance_cost_brl.to_f, unit: 'BRL')]
    ]

    if @simulation.modal == 'Marítimo'
      logistics_data += [
        ["Porto de Origem:", @simulation.origin_port.to_s],
        ["Porto de Destino:", @simulation.destination_port.to_s]
      ]
    elsif @simulation.modal == 'Aéreo'
      logistics_data += [
        ["Aeroporto de Origem:", @simulation.origin_airport.to_s],
        ["Aeroporto de Destino:", @simulation.destination_airport.to_s]
      ]
    end

    pad(10) do
      table(logistics_data, width: bounds.width) do |t|
        t.cells.borders = []
        t.cells.padding = [2, 5]
        t.columns(0).font_style = :bold
        t.columns(0).width = 150
      end
    end
  end

  def quotations_details
    text "Cotações", size: 12, style: :bold

    quotations_data = [["Produto", "NCM", "Preço", "Qtd.", "Total", "Fornecedor", "II%", "IPI%", "PIS%", "COFINS%", "ICMS%"]]
    @simulation.simulation_quotations.each do |sq|
      quotations_data << [
        sq.quotation.product.product_name,
        sq.quotation.product.ncm,
        @view.number_to_currency(sq.custom_price || sq.quotation.price, unit: sq.quotation.currency),
        sq.quantity,
        @view.number_to_currency(sq.total_value, unit: sq.quotation.currency),
        sq.quotation.supplier.trade_name,
        @view.number_to_percentage(sq.aliquota_ii || 0, precision: 2),
        @view.number_to_percentage(sq.aliquota_ipi || 0, precision: 2),
        @view.number_to_percentage(sq.aliquota_pis || 0, precision: 2),
        @view.number_to_percentage(sq.aliquota_cofins || 0, precision: 2),
        @view.number_to_percentage(sq.aliquota_icms || 0, precision: 2)
      ]
    end

    pad(5) do
      table(quotations_data, width: bounds.width) do |t|
        t.cells.size = 8
        t.cells.padding = [3, 3]
        t.row(0).font_style = :bold
        t.row_colors = ["F0F0F0", "FFFFFF"]
      end
    end
  end

  def taxes_and_expenses
    text "Impostos e Despesas", size: 12, style: :bold
    move_down 10

    taxes_data = [["Imposto", "Alíquota", "Valor (BRL)"]]
    taxes_data += [
      ["II", "#{@view.number_to_percentage(@simulation.aliquota_ii || 0, precision: 2)}", @view.number_to_currency(@simulation.tributo_ii.to_f, unit: 'BRL')],
      ["IPI", "#{@view.number_to_percentage(@simulation.aliquota_ipi || 0, precision: 2)}", @view.number_to_currency(@simulation.tributo_ipi.to_f, unit: 'BRL')],
      ["PIS", "#{@view.number_to_percentage(@simulation.aliquota_pis || 0, precision: 2)}", @view.number_to_currency(@simulation.tributo_pis.to_f, unit: 'BRL')],
      ["COFINS", "#{@view.number_to_percentage(@simulation.aliquota_cofins || 0, precision: 2)}", @view.number_to_currency(@simulation.tributo_cofins.to_f, unit: 'BRL')],
      ["ICMS", "#{@view.number_to_percentage(@simulation.aliquota_icms || 0, precision: 2)}", @view.number_to_currency(@simulation.tributo_icms.to_f, unit: 'BRL')]
    ]

    table(taxes_data, width: bounds.width) do |t|
      t.cells.padding = [3, 3]
      t.row(0).font_style = :bold
      t.row_colors = ["F0F0F0", "FFFFFF"]
    end

    move_down 15
    text "Despesas Operacionais", size: 12, style: :bold
    move_down 10

    expenses_data = [["Despesa", "Valor", "Localização"]]
    @simulation.simulation_expenses.each do |expense|
      expenses_data << [
        expense.expense_custom_name,
        @view.number_to_currency(expense.expense_custom_value, unit: expense.expense_currency),
        expense.expense_location
      ]
    end

    table(expenses_data, width: bounds.width) do |t|
      t.cells.padding = [3, 3]
      t.row(0).font_style = :bold
      t.row_colors = ["F0F0F0", "FFFFFF"]
    end
  end

  def summary
    text "Resumo da Importação", size: 12, style: :bold
    move_down 10

    summary_data = [
      ["Valor Aduaneiro Total (BRL):", @view.number_to_currency(@simulation.total_customs_value_brl.to_f, unit: 'BRL')],
      ["Valor Total de Impostos:", @view.number_to_currency(@simulation.total_taxes.to_f, unit: 'BRL')],
      ["Valor Total de Despesas Operacionais:", @view.number_to_currency(@simulation.total_operational_expenses.to_f, unit: 'BRL')],
      ["Valor Total da Importação:", @view.number_to_currency(@simulation.total_importation_cost.to_f, unit: 'BRL')],
      ["Fator de Importação:", @view.number_with_precision(@simulation.import_factor.to_f, precision: 2)]
    ]

    table(summary_data, width: bounds.width) do |t|
      t.cells.padding = [3, 5]
      t.cells.borders = []
      t.columns(0).font_style = :bold
    end

    draw_progress_bar("Composição do Custo Total", {
      "Aduaneiro" => @simulation.total_customs_value_brl,
      "Impostos" => @simulation.total_taxes,
      "Despesas" => @simulation.total_operational_expenses
    })
  end

  def footer
    go_to_page(page_count)
    bounding_box [bounds.left, bounds.bottom + 20], width: bounds.width do
      stroke_horizontal_rule
      move_down 5
      text "Gerado em: #{Time.current.strftime('%d/%m/%Y às %H:%M')} por #{@simulation.user.email}",
           size: 8, align: :center
    end
  end

  def draw_progress_bar(title, components)
    move_down 10
    text title, size: 10, style: :bold
    move_down 5

    total = components.values.sum
    components.each do |name, value|
      percentage = ((value / total.to_f) * 100).round
      text "#{name}: #{percentage}%", size: 9

      fill_color = case name
                  when "Produtos" then "007BFF"
                  when "Frete" then "FFA500"
                  when "Seguro" then "008000"
                  when "Impostos" then "FFC107"
                  when "Despesas" then "FF5733"
                  else "CCCCCC" # Valor padrão para nomes não especificados
                  end

      fill_rectangle([bounds.left, cursor], bounds.width * (percentage / 100.0), 10)
      fill_color "000000" # Reseta a cor para o texto padrão
      move_down 15
    end
  end
end
