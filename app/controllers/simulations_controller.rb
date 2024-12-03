class SimulationsController < ApplicationController
  def new
    @simulation = Simulation.new
  end

  def create
    @simulation = Simulation.new(simulation_params)
    if @simulation.save
      redirect_to root_path, notice: 'Simulação criada com sucesso.'
    else
      render :new
    end
  end

  private

  def simulation_params
    params.require(:simulation).permit(:origin_country, :total_value, :incoterm, :modal)
  end
end
