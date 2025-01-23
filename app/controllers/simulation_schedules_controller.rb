class SimulationSchedulesController < ApplicationController
  before_action :set_simulation
  before_action :set_simulation_schedule, only: [:edit, :update]

  def new
    @simulation_schedule = @simulation.build_simulation_schedule(
      start_date: Date.current,
      schedule_name: "Novo Cronograma",
      steps: default_steps
    )
  end

  def create
    @simulation_schedule = @simulation.build_simulation_schedule(simulation_schedule_params)

    if @simulation_schedule.save
      redirect_to simulation_path(@simulation), notice: "Cronograma vinculado com sucesso!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @simulation_schedule.update(simulation_schedule_params)
      redirect_to simulation_path(@simulation), notice: "Cronograma atualizado com sucesso!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_simulation
    @simulation = Simulation.find(params[:simulation_id])
  end

  def set_simulation_schedule
    @simulation_schedule = @simulation.simulation_schedule
  end

  def simulation_schedule_params
    params.require(:simulation_schedule).permit(:schedule_name, :start_date, steps: %i[name start_date end_date sla])
  end

  def default_steps
    Step.all.map do |step|
      {
        name: step.name,
        start_date: nil,
        end_date: nil,
        sla: step.default_sla
      }
    end
  end
end
