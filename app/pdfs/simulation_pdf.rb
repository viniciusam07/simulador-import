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
    footer
    add_page_numbers
  end

  def header
    image "#{Rails.root}/app/assets/images/mazzu_logo_alta.png", width: 120, position: :left
    move_down 5
    text "Simulação de Importação ##{@simulation.id}", size: 12, style: :bold, align: :center
    text "Data: #{@simulation.created_at.strftime('%d/%m/%Y')}", size: 9, align: :center
    move_down 10
    stroke_horizontal_rule
  end

  def general_and_logistics_section
    move_down 5

    column_width = (bounds.width - 20) / 2

    bounding_box([0, cursor], width: bounds.width) do
      # Coluna Esquerda - Dados Gerais
      bounding_box([0, cursor], width: column_width, height: 150) do
        text "Dados Gerais", size: 10, style: :bold
        move_down 3
        table(general_data, width: column_width) do |t|
          t.cells.borders = []
          t.cells.padding = [3, 3]
          t.row_colors = ["F9F9F9", "FFFFFF"]
          t.cells.size = 9
        end
      end

      # Coluna Direita - Dados Logísticos
      bounding_box([column_width + 10, cursor + 150], width: column_width, height: 150) do
        text "Dados Logísticos", size: 10, style: :bold
        move_down 3
        table(logistics_data, width: column_width) do |t|
          t.cells.borders = []
          t.cells.padding = [3, 3]
          t.row_colors = ["F9F9F9", "FFFFFF"]
          t.cells.size = 9
        end
      end
    end
  end

  def general_data
    [
      ["Empresa", @simulation.company&.name.to_s],
      ["CNPJ", @simulation.company&.cnpj.to_s],
      ["Incoterm", @simulation.incoterm.to_s],
      ["CFOP", "#{@simulation.cfop_code} - #{@simulation.cfop_description}"],
      ["Moeda", @simulation.currency.to_s],
      ["Taxa de Câmbio", @simulation.exchange_rate.to_s]
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
        ["Porto Destino", @simulation.destination_port.to_s]
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
      [{ content: "Composição de Valores", colspan: 3, font_style: :bold, size: 12, align: :center }],
      ["Descrição", "Valor (#{@simulation.currency})", "Valor (BRL)"],
      ["Valor Total Produtos", format_currency(@simulation.total_value), format_currency(@simulation.total_value_brl)],
      ["Frete", format_currency(@simulation.freight_cost), format_currency(@simulation.freight_cost_brl)],
      ["Seguro", format_currency(@simulation.insurance_cost), format_currency(@simulation.insurance_cost_brl)],
      ["Valor Aduaneiro", format_currency(@simulation.customs_value), format_currency(@simulation.total_customs_value_brl)]
    ]

    # Verificar espaço disponível dinamicamente
    check_table_space("Composição de Valores",data)

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
        format_currency(sq.custom_price || sq.quotation.price) || "N/A",
        sq.quantity || 0,
        format_currency(sq.total_value) || "N/A",
        format_currency(sq.freight_allocated || 0) || "N/A",
        format_currency(sq.insurance_allocated || 0) || "N/A",
        format_currency(sq.customs_unit_value || 0) || "N/A",
        format_currency(sq.customs_total_value || 0) || "N/A",
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

  def tax_summary
    move_down 5

    data = [
      [{ content: "Resumo dos Impostos", colspan: 3, font_style: :bold, size: 12, align: :center }],
      ["Imposto", "Valor (BRL)", "% do Total"],
      ["II", format_currency(@simulation.tributo_ii), format_percentage(@simulation.tributo_ii / @simulation.total_taxes)],
      ["IPI", format_currency(@simulation.tributo_ipi), format_percentage(@simulation.tributo_ipi / @simulation.total_taxes)],
      ["PIS", format_currency(@simulation.tributo_pis), format_percentage(@simulation.tributo_pis / @simulation.total_taxes)],
      ["COFINS", format_currency(@simulation.tributo_cofins), format_percentage(@simulation.tributo_cofins / @simulation.total_taxes)],
      ["ICMS", format_currency(@simulation.tributo_icms), format_percentage(@simulation.tributo_icms / @simulation.total_taxes)]
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
    move_down 5

    data = [
      [{ content: "Resumo Final da Importação", colspan: 2, font_style: :bold, size: 12, align: :center }],
      ["Descrição", "Valor"],
      ["Valor Total Aduaneiro", format_currency(@simulation.total_customs_value_brl)],
      ["Total de Impostos", format_currency(@simulation.total_taxes)],
      ["Total de Despesas", format_currency(@simulation.total_operational_expenses)],
      ["Custo Total da Importação", format_currency(@simulation.total_importation_cost)],
      ["Fator de Importação", format_number(@simulation.import_factor)]
    ]

    # Verificar espaço antes de renderizar
    check_table_space("Resumo Final da Importação", data)

    table(data, width: bounds.width) do |t|
      t.row(0).font_style = :bold
      t.cells.padding = [3, 3]
      t.row_colors = ["F9F9F9", "FFFFFF"]
      t.cells.size = 9
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

  def format_currency(value)
    @view.number_to_currency(value || 0, unit: 'BRL')
  end

  def format_percentage(value)
    @view.number_to_percentage(value || 0, precision: 2)
  end

  def format_number(value)
    @view.number_with_precision(value || 0, precision: 2)
  end
end
