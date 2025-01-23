class SchedulesController < ApplicationController
  before_action :set_schedule, only: [:edit, :update, :destroy]

  def index
    @schedules = Schedule.all
  end

  def new
    @schedule = Schedule.new
    @steps = Step.all
  end

  def create
    @schedule = Schedule.new(schedule_params)

    if @schedule.save
      redirect_to schedules_path, notice: "Cronograma criado com sucesso!"
    else
      @steps = Step.all
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @steps = Step.all
  end

  def update
    if @schedule.update(schedule_params)
      redirect_to schedules_path, notice: "Cronograma atualizado com sucesso!"
    else
      @steps = Step.all
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @schedule.destroy
    redirect_to schedules_path, notice: "Cronograma excluído com sucesso!"
  end

  private

  def set_schedule
    @schedule = Schedule.find(params[:id])
  end

  def schedule_params
    params.require(:schedule).permit(
      :name, schedule_steps_attributes: [:id, :step_id, :order, :_destroy]
    )
  end
end
