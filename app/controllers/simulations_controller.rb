class SimulationsController < ApplicationController
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
      attach_selected_expenses
      attach_selected_quotations
      attach_afrmm_if_needed

      @simulation.calculate_total_value # Recalcula o total_value
      @simulation.save

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
    @simulation.simulation_quotations.build if @simulation.simulation_quotations.empty?
  end

  def update
    @simulation = Simulation.find(params[:id])

    if @simulation.update(simulation_params)
      attach_selected_expenses
      attach_selected_quotations

      @simulation.calculate_total_value # Recalcula o total_value
      @simulation.save
      redirect_to simulation_path(@simulation), notice: 'Simulação atualizada com sucesso.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def index
    @simulations = Simulation.where(user_id: current_user.id)
    @pagy, @simulations = pagy(Simulation.where(user_id: current_user.id), items: 10)
  end

  def show
    @simulation = Simulation.includes(simulation_quotations: { quotation: [:product, :supplier] }).find(params[:id])
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
    respond_to do |format|
      format.pdf do
        pdf = SimulationPdf.new(@simulation, view_context)
        send_data pdf.render,
                filename: "simulacao_#{@simulation.id}.pdf",
                type: 'application/pdf',
                disposition: 'attachment'
      end
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
      :equipment_id, :equipment_quantity,
      :cbm_total, :weight_net_total, :weight_gross_total,
      expense_ids: [],
      simulation_quotations_attributes: [:id, :quotation_id, :quantity, :custom_price, :total_value, :aliquota_ii, :aliquota_ipi, :aliquota_pis, :aliquota_cofins, :aliquota_icms, :_destroy]
    )
  end

  def attach_selected_expenses
    selected_expenses = Expense.where(id: params[:simulation][:expense_ids])

    selected_expenses.each do |expense|
      @simulation.simulation_expenses.find_or_create_by!(expense: expense) do |sim_expense|
        sim_expense.expense_custom_name = expense.expense_name
        sim_expense.expense_custom_value = sim_expense.calculate_custom_value
        sim_expense.expense_currency = expense.expense_currency
        sim_expense.expense_location = expense.expense_location
        sim_expense.save!
      end
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
end
