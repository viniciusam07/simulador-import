class SimulationPdf < Prawn::Document
  def initialize(simulation, view, unit_cost_summary)
    super(
      page_size: "A4",
      margin: [30, 30, 30, 30],
      info: {
        Title: "Simulação de Importação ##{simulation.id}",
        Author: simulation.user.email,
        Creator: "Heyship Import",
        CreationDate: Time.current
      }
    )
    font_families.update(
      "OpenSans" => {
        normal: Rails.root.join("app/assets/fonts/OpenSans-Regular.ttf"),
        bold: Rails.root.join("app/assets/fonts/OpenSans-Bold.ttf"),
        italic: Rails.root.join("app/assets/fonts/OpenSans-Italic.ttf"),
        bold_italic: Rails.root.join("app/assets/fonts/OpenSans-BoldItalic.ttf")
      }
    )
    font "OpenSans"
    @simulation = simulation
    @view = view
    @unit_cost_summary = unit_cost_summary
    generate
  end

  private

  def generate
    header
    move_down 10
    general_and_logistics_section
    move_down 10
    value_composition
    move_down 10
    tax_summary
    move_down 10
    expenses_section
    move_down 10
    final_summary
    move_down 10
    quotations_section
    move_down 10
    unit_costs_summary_section
    footer
    add_page_numbers
  end

  def header
    image "#{Rails.root}/app/assets/images/heyship_logo_alta.png", width: 120, position: :left
    move_down 5
    text "Simulação de Importação ##{@simulation.id}", size: 12, style: :bold, align: :center
    text "Data: #{@simulation.created_at.strftime('%d/%m/%Y')}", size: 9, align: :center
    move_down 10
    stroke_horizontal_rule
  end

  def general_and_logistics_section
    move_down 5

    text "Dados Gerais", size: 10, style: :bold
    move_down 3

    table(general_data, width: bounds.width, cell_style: { overflow: :truncate }) do |t|
      t.cells.borders = []
      t.cells.padding = [3, 3]
      t.row_colors = ["F9F9F9", "FFFFFF"]
      t.cells.size = 9
      t.columns(1).style(overflow: :truncate)
    end

    move_down 10

    text "Dados Logísticos", size: 10, style: :bold
    move_down 3

    table(logistics_data, width: bounds.width, cell_style: { overflow: :truncate }) do |t|
      t.cells.borders = []
      t.cells.padding = [3, 3]
      t.row_colors = ["F9F9F9", "FFFFFF"]
      t.cells.size = 9
    end
  end

  def general_data
    [
      ["Empresa", @simulation.company&.name.to_s],
      ["CNPJ", @simulation.company&.cnpj.to_s],
      ["Regime Tributário", @simulation.company.tax_regime.to_s],
      ["Incoterm", @simulation.incoterm.to_s],
      ["CFOP", "#{@simulation.cfop_code} - #{@simulation.cfop_description}"],
      ["Moeda da Mercadoria", @simulation.currency.to_s],
      ["Câmbio Mercadoria", @simulation.exchange_rate_goods.to_s],
      ["Moeda do Frete", @simulation.currency_freight.to_s],
      ["Câmbio Frete", @simulation.exchange_rate_freight.to_s],
      ["Moeda do Seguro", @simulation.currency_insurance.to_s],
      ["Câmbio Seguro", @simulation.exchange_rate_insurance.to_s]
    ]
  end

  def logistics_data
    data = [
      ["País de Origem", @simulation.origin_country.to_s],
      ["Estado Destino", @simulation.destination_state.to_s],
      ["Modal", @simulation.modal.to_s]
    ]

    if @simulation.modal == 'Marítimo'
      data += [
        ["Porto Origem", @simulation.origin_port.to_s],
        ["Porto Destino", @simulation.destination_port.to_s],
        ["Equipamento e Qtd", "#{@simulation.equipment.name.to_s} x #{@simulation.equipment_quantity.to_s}"],
        ["Tipo de Carga", @simulation.cargo_type.to_s]
      ]
    elsif @simulation.modal == 'Aéreo'
      data += [
        ["Aeroporto Origem", @simulation.origin_airport.to_s],
        ["Aeroporto Destino", @simulation.destination_airport.to_s]
      ]
    end
    data
  end

  def value_composition
    data = [
      [{ content: "Composição de Valores", colspan: 4, font_style: :bold, size: 12, align: :center }],
      ["Descrição", "Valor (Original)", "Moeda", "Valor (BRL)"]
    ]

    data << ["Valor Total Produtos", format_currency(@simulation.total_value, @simulation.currency), @simulation.currency, format_currency(@simulation.total_value_brl)]
    data << ["Frete", format_currency(@simulation.freight_cost, @simulation.currency_freight), @simulation.currency_freight, format_currency(@simulation.freight_cost_brl)]
    data << ["Seguro", format_currency(@simulation.insurance_cost, @simulation.currency_insurance), @simulation.currency_insurance, format_currency(@simulation.insurance_cost_brl)]
    data << ["Valor Aduaneiro Total", format_currency(@simulation.customs_value, @simulation.currency), @simulation.currency, format_currency(@simulation.total_customs_value_brl)]

    check_table_space("Composição de Valores", data)

    table(data, width: bounds.width) do |t|
      t.row(0).font_style = :bold
      t.cells.padding = [3, 3]
      t.row_colors = ["F9F9F9", "FFFFFF"]
      t.cells.size = 9
    end
  end

  def quotations_section
    # Adiciona uma nova página em layout horizontal
    start_new_page(layout: :landscape)

    # Título da página
    text "Cotações de Produtos", size: 16, style: :bold, align: :center
    move_down 10

    # Dados da tabela
    data = [
      ["Produto", "NCM", "Preço Unitário", "Quantidade", "Valor Total", "Frete Alocado", "Seguro Alocado",
      "Valor Aduaneiro Unitário", "Valor Aduaneiro Total", "Fornecedor",
      "II (%)", "II (R$)", "IPI (%)", "IPI (R$)",
      "PIS (%)", "PIS (R$)", "COFINS (%)", "COFINS (R$)", "ICMS (%)", "ICMS (R$)"]
    ]

    @simulation.simulation_quotations.each do |sq|
      data << [
        sq.quotation.product.product_name || "N/A",
        sq.quotation.product.ncm || "N/A",
        format_currency(sq.custom_price || sq.quotation.price, @simulation.currency) || "N/A",
        sq.quantity || 0,
        format_currency(sq.total_value, @simulation.currency) || "N/A",
        format_currency(sq.freight_allocated || 0, @simulation.currency) || "N/A",
        format_currency(sq.insurance_allocated || 0, @simulation.currency) || "N/A",
        format_currency(sq.customs_unit_value || 0, @simulation.currency) || "N/A",
        format_currency(sq.customs_total_value || 0, @simulation.currency) || "N/A",
        sq.quotation.supplier.trade_name || "N/A",
        format_percentage(sq.aliquota_ii || 0) || "N/A",
        format_currency(sq.tributo_ii || 0) || "N/A",
        format_percentage(sq.aliquota_ipi || 0) || "N/A",
        format_currency(sq.tributo_ipi || 0) || "N/A",
        format_percentage(sq.aliquota_pis || 0) || "N/A",
        format_currency(sq.tributo_pis || 0) || "N/A",
        format_percentage(sq.aliquota_cofins || 0) || "N/A",
        format_currency(sq.tributo_cofins || 0) || "N/A",
        format_percentage(sq.aliquota_icms || 0) || "N/A",
        format_currency(sq.tributo_icms || 0) || "N/A"
      ]
    end

    # Verificar espaço antes de renderizar
    check_table_space("Cotações de Produtos", data)

    # Ajusta o tamanho da fonte dinamicamente
    font_size = adjust_font_for_table(data)

    # Renderiza a tabela com o tamanho ajustado
    font_size(font_size) do
      table(data, width: bounds.width, header: true) do |t|
        t.row(0).font_style = :bold
        t.row(0).background_color = "F0F0F0"
        t.row_colors = ["F9F9F9", "FFFFFF"]
        t.cells.padding = [3, 3]
        t.cells.size = font_size
      end
    end
  end
  def unit_costs_summary_section
    # Cria uma nova página em formato horizontal
    start_new_page(layout: :landscape)

    # Título da página
    text "Resumo de Custos Unitários e Rateio", size: 16, style: :bold, align: :center
    move_down 10

    # Dados da tabela
    data = [
      ["Produto", "Quantidade", "Preço Unitário (FOB em BRL)", "Custo Logístico (BRL/unidade)",
      "Custo de Impostos (BRL/unidade)", "Custo Operacional (BRL/unidade)",
      "Custo Total Unitário (BRL)", "Fator de Importação Unitário"]
    ]

    @unit_cost_summary.each do |summary|
      data << [
        summary[:product_name],
        summary[:quantity],
        format_currency(summary[:unit_price_brl]),
        format_currency(summary[:logistic_cost_per_unit]),
        format_currency(summary[:tax_cost_per_unit]),
        format_currency(summary[:operational_cost_per_unit]),
        format_currency(summary[:total_unit_inventory_cost]),
        summary[:unit_import_factor]
      ]
    end

    # Ajusta o tamanho da fonte dinamicamente
    font_size = adjust_font_for_table(data)

    # Renderiza a tabela com o tamanho ajustado
    font_size(font_size) do
      table(data, width: bounds.width, header: true) do |t|
        t.row(0).font_style = :bold
        t.row(0).background_color = "F0F0F0"
        t.row_colors = ["F9F9F9", "FFFFFF"]
        t.cells.padding = [3, 3]
        t.cells.size = font_size
      end
    end
  end

  def tax_summary
    move_down 5

    data = [
      [{ content: "Resumo dos Impostos Totais", colspan: 3, font_style: :bold, size: 12, align: :center }],
      ["Imposto", "Percentual (%)", "Valor (BRL)"],
      ["Imposto de Importação (II)",
      format_percentage((@simulation.tributo_ii || 0) / (@simulation.total_taxes || 1) * 100),
      format_currency(@simulation.tributo_ii)],
      ["Imposto sobre Produtos Industrializados (IPI)",
      format_percentage((@simulation.tributo_ipi || 0) / (@simulation.total_taxes || 1) * 100),
      format_currency(@simulation.tributo_ipi)],
      ["PIS-Importação",
      format_percentage((@simulation.tributo_pis || 0) / (@simulation.total_taxes || 1) * 100),
      format_currency(@simulation.tributo_pis)],
      ["COFINS-Importação",
      format_percentage((@simulation.tributo_cofins || 0) / (@simulation.total_taxes || 1) * 100),
      format_currency(@simulation.tributo_cofins)],
      ["ICMS",
      format_percentage((@simulation.tributo_icms || 0) / (@simulation.total_taxes || 1) * 100),
      format_currency(@simulation.tributo_icms)]
    ]

    # Verificar espaço antes de renderizar
    check_table_space("Despesas Operacionais", data)

    table(data, width: bounds.width) do |t|
      t.row(0).font_style = :bold
      t.cells.padding = [3, 3]
      t.row_colors = ["F9F9F9", "FFFFFF"]
      t.cells.size = 9
    end
  end

  def expenses_section
    move_down 5

    data = [
      [{ content: "Despesas Operacionais", colspan: 3, font_style: :bold, size: 12, align: :center }],
      ["Nome", "Valor", "Localização"]
    ]
    @simulation.simulation_expenses.each do |expense|
      data << [
        expense.expense_custom_name,
        format_currency(expense.expense_custom_value),
        expense.expense_location
      ]
    end

    # Verificar espaço antes de renderizar
    check_table_space("Despesas Operacionais", data)


    table(data, width: bounds.width) do |t|
      t.row(0).font_style = :bold
      t.cells.padding = [3, 3]
      t.row_colors = ["F9F9F9", "FFFFFF"]
      t.cells.size = 9
    end
  end

  def final_summary
    # Configuração para duas colunas lado a lado
    move_down 10
    text "Resumo Final da Importação", size: 12, style: :bold, align: :center
    move_down 5

    column_width = (bounds.width - 20) / 2

    # Ajusta o cursor para considerar o espaço da tabela superior
    move_down 10

    bounding_box([0, cursor], width: bounds.width, height: 200) do
      # Coluna Esquerda: Tabela
      bounding_box([0, cursor], width: column_width, height: 150) do
        data = [
          ["Descrição", "Valor"],
          ["Valor Total Aduaneiro", format_currency(@simulation.total_customs_value_brl)],
          ["Total de Impostos", format_currency(@simulation.total_taxes)],
          ["Total de Despesas", format_currency(@simulation.total_operational_expenses)],
          ["Custo Total da Importação", format_currency(@simulation.total_importation_cost)],
          ["Fator de Importação", format_number(@simulation.import_factor)]
        ]

        table(data, width: column_width) do |t|
          t.row(0).font_style = :bold
          t.row(0).background_color = "F0F0F0"
          t.cells.padding = [3, 3]
          t.row_colors = ["F9F9F9", "FFFFFF"]
          t.cells.size = 9
        end
      end

      # Coluna Direita: Gráfico
      bounding_box([column_width + 10, cursor + 150], width: column_width, height: 150) do
        # Dados do gráfico
        graph_data = {
          "Valor Total Aduaneiro" => @simulation.total_customs_value_brl,
          "Total de Impostos" => @simulation.total_taxes,
          "Total de Despesas" => @simulation.total_operational_expenses
        }

        # Gera o gráfico e insere no PDF
        chart_path = generate_pie_chart(graph_data)
        image chart_path, position: :center, fit: [column_width - 10, 150]

        # Remove o gráfico temporário
        File.delete(chart_path) if File.exist?(chart_path)
      end
    end
  end

  def footer
    bounding_box [bounds.left, bounds.bottom + 30], width: bounds.width do
      stroke_horizontal_rule
      move_down 5
      text "Gerado em: #{Time.current.strftime('%d/%m/%Y às %H:%M')} por #{@simulation.user.email}",
          size: 8, align: :center
    end
  end

  def adjust_font_for_table(data, options = {})
    # Tamanhos de fonte disponíveis
    font_sizes = options[:font_sizes] || [9, 8, 7, 6]

    # Itera sobre os tamanhos de fonte
    font_sizes.each do |size|
      pdf_temp = Prawn::Document.new(page_size: "A4")
      pdf_temp.font_size(size) do
        pdf_temp.bounding_box([0, pdf_temp.cursor], width: bounds.width) do
          begin
            pdf_temp.table(data, width: bounds.width, cell_style: { padding: [3, 3], size: size })
          rescue Prawn::Errors::CannotFit
            next # Tente o próximo tamanho de fonte
          end
        end
      end

      # Retorna o tamanho da fonte se couber
      return size
    end

    # Retorna o menor tamanho de fonte se nenhum couber perfeitamente
    font_sizes.last
  end

  def check_table_space(title, data)
    # Calcula altura do título
    title_height = title.empty? ? 0 : height_of(title, size: 12) + 10

    # Calcula altura da tabela
    rows = data.size
    header_height = 25
    row_height = 20
    table_height = (rows * row_height) + header_height

    # Altura total necessária
    total_height = title_height + table_height

    # Verifica espaço na página
    start_new_page if cursor < total_height + 20
  end

  def estimate_table_height(data)
    # Estima a altura necessária para a tabela com base no número de linhas e espaçamento
    rows = data.size
    header_height = 25
    row_height = 20
    header_height + (rows * row_height)
  end

  def add_page_numbers
    page_count.times do |i|
      go_to_page(i + 1)
      layout = page.layout

      x_position = layout == :landscape ? bounds.right - 150 : bounds.right - 100
      y_position = bounds.bottom + 15

      bounding_box([x_position, y_position], width: 100, height: 20) do
        text "Página #{i + 1} de #{page_count}", size: 8, align: :right
      end
    end
  end

  def format_currency(value, currency = 'BRL')
    unit = case currency
          when 'USD' then '$'
          when 'EUR' then '€'
          when 'GBP' then '£'
          else 'R$'
          end
    @view.number_to_currency(value || 0, unit: unit)
  end

  def generate_pie_chart(data)
    require 'gruff'

    # Inicializa o gráfico
    g = Gruff::Pie.new(400) # Define o tamanho do gráfico
    g.theme = {
      colors: ['#3366CC', '#DC3912', '#FF9900'], # Paleta de cores
      marker_color: '#AAAAAA',
      font_color: '#333333',
      background_colors: ['#FFFFFF', '#FFFFFF']
    }

    # Exibe a legenda fora do gráfico
    g.hide_legend = false
    g.legend_at_bottom = true # Coloca a legenda na parte inferior
    g.legend_font_size = 30 # Ajusta o tamanho da fonte da legenda

    # Adiciona os dados ao gráfico com rótulos simples
    data.each do |label, value|
      g.data(label, value) # Apenas o nome da categoria
    end

    # Salva o gráfico em um arquivo temporário
    file_path = Rails.root.join("tmp", "chart_#{SecureRandom.uuid}.png")
    g.write(file_path)
    file_path.to_s
  end

  def format_percentage(value)
    @view.number_to_percentage(value || 0, precision: 2)
  end

  def format_number(value)
    @view.number_with_precision(value || 0, precision: 2)
  end
end
