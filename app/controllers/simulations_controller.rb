class SimulationsController < ApplicationController
  def new
    @simulation = Simulation.new
  end

  def create
    @simulation = Simulation.new(simulation_params)
    @simulation.user_id = current_user.id

    if @simulation.save
      attach_selected_expenses
      attach_afrmm_if_needed

      redirect_to simulation_path(@simulation), notice: 'Simulação criada com sucesso.'
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
    params.require(:simulation).permit(
      :origin_country, :total_value, :incoterm, :modal, :currency, :exchange_rate,
      :freight_cost, :insurance_cost, :aliquota_ii, :tributo_ii, :aliquota_ipi, :tributo_ipi,
      :aliquota_pis, :tributo_pis, :aliquota_cofins, :tributo_cofins, :aliquota_icms, :tributo_icms,
      expense_ids: []
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
