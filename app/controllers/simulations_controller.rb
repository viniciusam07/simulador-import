class SimulationsController < ApplicationController
  def new
    @simulation = Simulation.new
  end

  def create
    @simulation = Simulation.new(simulation_params)
    @simulation.user_id = current_user.id

    if @simulation.save
      # Associa despesas selecionadas
      selected_expenses = Expense.where(id: params[:simulation][:expense_ids])

      Rails.logger.debug "Expense IDs: #{params[:simulation][:expense_ids]}"

      selected_expenses.each do |expense|
        unless @simulation.simulation_expenses.exists?(expense_id: expense.id)
          @simulation.simulation_expenses.create!(
            expense: expense,
            expense_custom_name: expense.expense_name,
            expense_custom_value: expense.expense_default_value,
            expense_currency: expense.expense_currency,
            expense_location: expense.expense_location
          )
        end
      end

      redirect_to root_path, notice: 'Simulação criada com sucesso.'
    else
      render :new, alert: 'Erro ao criar a simulação.'
    end
  end

  def index
    @simulations = Simulation.where(user_id: current_user.id)
  end

  def show
    @simulation = Simulation.find(params[:id])
  end

  def exchange_rate
    currency = params[:currency]
    bank = EuCentralBank.new
    bank.update_rates
    rate = bank.exchange(100, currency, 'BRL').to_f / 100
    render json: { rate: rate }
  end

  private

  def simulation_params
    params.require(:simulation).permit(:origin_country, :total_value, :incoterm, :modal, :currency, :exchange_rate, :freight_cost, :insurance_cost, :aliquota_ii, :tributo_ii, :aliquota_ipi, :tributo_ipi, :aliquota_pis, :tributo_pis, :aliquota_cofins, :tributo_cofins, :aliquota_icms, :tributo_icms, expense_ids: [])
  end
end
