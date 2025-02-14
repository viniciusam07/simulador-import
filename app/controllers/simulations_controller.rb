class SimulationsController < ApplicationController
  before_action :set_simulation, only: %i[show edit update update_status destroy]
  def new
    @simulation = Simulation.new
    @simulation.simulation_quotations.build # Permite criar associações diretamente
  end

  def create
    @simulation = Simulation.new(simulation_params)
    @simulation.user_id = current_user.id

    # Preenche automaticamente a descrição do CFOP com base no código selecionado
    if @simulation.cfop_code.present?
      @simulation.cfop_description = Simulation::CFOPS[@simulation.cfop_code]
    end

    if @simulation.save
      PaperTrail.request(enabled: false) do
        # Recalcula o total_value
        @simulation.calculate_total_value
        @simulation.save!

        attach_selected_expenses
        attach_selected_quotations
        attach_afrmm_if_needed

        # Garante que as despesas sejam recalculadas
        @simulation.simulation_expenses.each(&:recalculate_custom_value)
        @simulation.save!
      end

      # Redireciona para a página de sucesso
      redirect_to simulation_path(@simulation), notice: 'Simulação criada com sucesso.'
    else
      # Adiciona mensagens de erro ao flash
      flash.now[:alert] = "Houve problemas ao salvar a simulação. Verifique os erros abaixo."
      render :new, status: :unprocessable_entity
    end
  end
  def edit
    @simulation = Simulation.find(params[:id])
  end
  def update
    @simulation = Simulation.find(params[:id])

    ActiveRecord::Base.transaction do
      if @simulation.update(simulation_params.except(:simulation_quotations_attributes))
        attach_selected_expenses
        update_or_create_simulation_quotations # Novo método para manipular as quotations

        @simulation.simulation_expenses.each(&:recalculate_custom_value)
        @simulation.save!

        redirect_to simulation_path(@simulation), notice: 'Simulação atualizada com sucesso.'
      else
        flash.now[:alert] = 'Erro ao atualizar a simulação. Verifique os campos e tente novamente.'
        render :edit, status: :unprocessable_entity
      end
    rescue => e
      Rails.logger.error "Erro ao atualizar a simulação: #{e.message}"
      flash.now[:alert] = 'Erro ao atualizar a simulação. Verifique os campos e tente novamente.'
      render :edit, status: :unprocessable_entity
    end
  end
  def index
    @simulations = Simulation.where(user_id: current_user.id)
    @pagy, @simulations = pagy(Simulation.where(user_id: current_user.id), items: 10)
  end

  def destroy
    @simulation.destroy
    redirect_to simulations_path, notice: "Simulação excluída com sucesso."
  end
  def show
    @simulation = Simulation.includes(simulation_quotations: { quotation: [:product, :supplier] }).find(params[:id])
    @unit_cost_summary = @simulation.unit_cost_summary

    # Obtendo os valores brutos
    total_aduaneiro = @simulation.total_customs_value_brl || 0
    total_impostos = @simulation.total_taxes || 0
    total_despesas = @simulation.total_operational_expenses || 0

    # Calculando o total geral
    total_importacao = total_aduaneiro + total_impostos + total_despesas

    # Evita divisão por zero e calcula as porcentagens
    if total_importacao > 0
      @import_sum_pie_chart = {
        "Valor Total Aduaneiro" => ((total_aduaneiro / total_importacao) * 100).round(2),
        "Valor Total de Impostos" => ((total_impostos / total_importacao) * 100).round(2),
        "Despesas Operacionais" => ((total_despesas / total_importacao) * 100).round(2)
      }
    else
      @import_sum_pie_chart = {
        "Valor Total Aduaneiro" => 0,
        "Valor Total de Impostos" => 0,
        "Despesas Operacionais" => 0
      }
    end
  end
  def exchange_rate
    currency = params[:currency]
    bank = EuCentralBank.new
    bank.update_rates
    rate = bank.exchange(100, currency, 'BRL').to_f
    render json: { rate: rate }
  end
  def generate_pdf
    @simulation = Simulation.includes(simulation_quotations: { quotation: [:product, :supplier] }).find(params[:id])

    # Calcula @unit_cost_summary antes de gerar o PDF
    @unit_cost_summary = @simulation.simulation_quotations.map do |sq|
      {
        product_name: sq.quotation.product.product_name || "N/A",
        quantity: sq.quantity || 0,
        unit_price_brl: sq.unit_price_brl,
        logistic_cost_per_unit: sq.logistic_cost_per_unit,
        tax_cost_per_unit: sq.tax_cost_per_unit,
        operational_cost_per_unit: sq.operational_cost_per_unit,
        total_unit_inventory_cost: sq.total_unit_inventory_cost,
        unit_import_factor: sq.unit_import_factor
      }
    end

    respond_to do |format|
      format.pdf do
        pdf = SimulationPdf.new(@simulation, view_context, @unit_cost_summary)
        send_data pdf.render,
                  filename: "simulacao_#{@simulation.id}.pdf",
                  type: 'application/pdf',
                  disposition: 'attachment'
      end
    end
  end

  # Atualiza o status da simulação manualmente
  def update_status
    Rails.logger.debug "Params recebidos: #{params.inspect}" # Log para depuração

    if params[:status].present?
      if @simulation.update_column(:status, params[:status])
        redirect_to simulation_path(@simulation), notice: "Status atualizado para #{@simulation.human_status}."
      else
        redirect_to simulation_path(@simulation), alert: "Erro ao atualizar o status."
      end
    else
      redirect_to simulation_path(@simulation), alert: "Status não pode ser vazio."
    end
  end

  private

  def simulation_params
    params.require(:simulation).permit(
      :origin_country, :incoterm, :modal, :currency, :exchange_rate,
      :freight_cost, :insurance_cost,
      :origin_country,
      :destination_state,
      :modal,
      :origin_port, :destination_port,
      :origin_airport, :destination_airport,
      :cfop_code, :cfop_description,
      :company_id,
      :equipment_id, :equipment_quantity, :cargo_type,
      :cbm_total, :weight_net_total, :weight_gross_total,
      :observations,
      expense_ids: [],
      simulation_quotations_attributes: [:id, :quotation_id, :quantity, :custom_price, :total_value, :aliquota_ii, :aliquota_ipi, :aliquota_pis, :aliquota_cofins, :aliquota_icms, :_destroy]
    )
  end

  def set_simulation
    @simulation = Simulation.find(params[:id])
  end

  def attach_selected_expenses
    selected_expenses = Expense.where(id: params[:simulation][:expense_ids])

    selected_expenses.each do |expense|
      sim_expense = @simulation.simulation_expenses.find_or_initialize_by(expense: expense)
      sim_expense.assign_attributes(
        expense_custom_name: expense.expense_name,
        expense_currency: expense.expense_currency,
        expense_location: expense.expense_location
      )
      sim_expense.save! # Chama o callback `before_save` para recalcular o valor customizado
    end
  end

  def attach_selected_quotations
    selected_quotations = params.dig(:simulation, :simulation_quotations_attributes)

    return if selected_quotations.blank? # Retorna se não houver cotações

    existing_quotation_ids = @simulation.simulation_quotations.pluck(:quotation_id)

    selected_quotations.each do |quotation_params|
      next if quotation_params[:_destroy] == "true"

      begin
        quotation_id = quotation_params[:quotation_id].to_i

        # Verifica duplicidade antes de adicionar a cotação
        if existing_quotation_ids.include?(quotation_id)
          Rails.logger.warn "A cotação #{quotation_id} já está associada a esta simulação."
          next
        end

        # Cria ou atualiza a cotação
        quotation = Quotation.find(quotation_id)
        @simulation.simulation_quotations.create!(
          quotation: quotation,
          quantity: quotation_params[:quantity],
          custom_price: quotation_params[:custom_price]
        )
        existing_quotation_ids << quotation_id # Atualiza a lista de IDs existentes
      rescue ActiveRecord::RecordNotFound
        Rails.logger.warn "Quotation não encontrada: #{quotation_params[:quotation_id]}"
      rescue ActiveRecord::RecordInvalid => e
        Rails.logger.error "Erro ao adicionar cotação: #{e.message}"
      end
    end
  end

  def attach_afrmm_if_needed
    return unless @simulation.modal == 'Marítimo'

    afrmm = Expense.find_by(expense_name: 'AFRMM')
    return unless afrmm

    @simulation.simulation_expenses.find_or_create_by!(expense: afrmm) do |sim_expense|
      sim_expense.expense_custom_name = afrmm.expense_name
      sim_expense.expense_custom_value = calculate_expense_value(afrmm)
      sim_expense.expense_currency = afrmm.expense_currency
      sim_expense.expense_location = afrmm.expense_location
    end
  end

  def calculate_expense_value(expense)
    if expense.percentage.present?
      case expense.calculation_base
      when 'freight_cost'
        @simulation.freight_cost * (expense.percentage / 100.0)
      when 'customs_value'
        @simulation.customs_value * (expense.percentage / 100.0)
      when 'total_value'
        @simulation.total_value * (expense.percentage / 100.0)
      else
        0
      end
    else
      expense.expense_default_value
    end
  end
  def update_or_create_simulation_quotations
    return unless params[:simulation][:simulation_quotations_attributes]

    params[:simulation][:simulation_quotations_attributes].each do |_, attributes|
      next if attributes[:_destroy] == "true" # Ignora registros marcados para exclusão

      quotation_id = attributes[:quotation_id].to_i
      existing_record = @simulation.simulation_quotations.find_by(quotation_id: quotation_id)

      if existing_record
        # Atualiza o registro existente
        existing_record.update!(
          quantity: attributes[:quantity],
          custom_price: attributes[:custom_price],
          total_value: attributes[:total_value],
          aliquota_ii: attributes[:aliquota_ii],
          aliquota_ipi: attributes[:aliquota_ipi],
          aliquota_pis: attributes[:aliquota_pis],
          aliquota_cofins: attributes[:aliquota_cofins],
          aliquota_icms: attributes[:aliquota_icms]
        )
      else
        # Cria um novo registro
        @simulation.simulation_quotations.create!(
          quotation_id: quotation_id,
          quantity: attributes[:quantity],
          custom_price: attributes[:custom_price],
          total_value: attributes[:total_value],
          aliquota_ii: attributes[:aliquota_ii],
          aliquota_ipi: attributes[:aliquota_ipi],
          aliquota_pis: attributes[:aliquota_pis],
          aliquota_cofins: attributes[:aliquota_cofins],
          aliquota_icms: attributes[:aliquota_icms]
        )
      end
    end
  end
end
