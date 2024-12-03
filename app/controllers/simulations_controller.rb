class SimulationsController < ApplicationController
  def new
    @simulation = Simulation.new
  end

  def create
    @simulation = Simulation.new(simulation_params)
    @simulation.user_id = current_user.id
    if @simulation.save
      redirect_to root_path, notice: 'Simulação criada com sucesso.'
    else
      render :new
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
    params.require(:simulation).permit(:origin_country, :total_value, :incoterm, :modal, :currency, :freight_cost, :insurance_cost)
  end
end
