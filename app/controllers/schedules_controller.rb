class SchedulesController < ApplicationController
  before_action :set_schedule, only: [:edit, :update, :destroy]
  before_action :initialize_schedule, only: [:new, :add_step, :remove_step]


  def index
    @schedules = Schedule.all
  end

  def new
    @schedule = Schedule.new
    @steps = Step.all
  end

  def create
    @schedule = Schedule.new(schedule_params)

    if @schedule.schedule_steps.any? { |ss| ss.step_id.blank? || ss.order.blank? }
      @schedule.errors.add(:schedule_steps, "Etapas inválidas ou incompletas.")
      @steps = Step.all
      render :new, status: :unprocessable_entity
      return
    end

    if @schedule.save
      redirect_to schedules_path, notice: "Cronograma criado com sucesso!"
    else
      logger.error @schedule.errors.full_messages
      @steps = Step.all
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @steps = Step.all
    @schedule.schedule_steps.each_with_index do |schedule_step, index|
      schedule_step.order ||= index + 1
    end
  end

  def update
    if @schedule.update(schedule_params)
      redirect_to schedules_path, notice: "Cronograma atualizado com sucesso!"
    else
      logger.error "Erro ao atualizar cronograma: #{@schedule.errors.full_messages}"
      @steps = Step.all
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @schedule.destroy
    redirect_to schedules_path, notice: "Cronograma excluído com sucesso!"
  end

  def add_step
    step = Step.find(params[:step_id])
    @schedule.schedule_steps.build(step: step, order: @schedule.schedule_steps.size + 1)

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("selected_steps", partial: "schedules/selected_steps", locals: { schedule: @schedule }),
          turbo_stream.replace("available_steps", partial: "schedules/available_steps", locals: { steps: available_steps })
        ]
      end
    end
  end

  def remove_step
    step = Step.find(params[:step_id])
    @schedule = Schedule.find(params[:id])
    @schedule.schedule_steps.find_by(step: step)&.destroy

    # Reordenar os steps na memória
    @schedule.schedule_steps.each_with_index do |ss, index|
      ss.order = index + 1
    end

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("selected_steps", partial: "schedules/selected_steps", locals: { schedule: @schedule }),
          turbo_stream.replace("available_steps", partial: "schedules/available_steps", locals: { steps: available_steps })
        ]
      end
    end
  end
  def details
    schedule = Schedule.find(params[:id])

    steps = schedule.schedule_steps.map do |schedule_step|
      {
        name: schedule_step.step.name,
        sla: schedule_step.step.default_sla,

      }
    end

    render json: { id: schedule.id, name: schedule.name, steps: steps }
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Cronograma não encontrado" }, status: :not_found
  end

  private

  def set_schedule
    @schedule = Schedule.find(params[:id])
  end

  def initialize_schedule
    @schedule = Schedule.new(schedule_steps: [])
  end

  def available_steps
    Step.where.not(id: @schedule.schedule_steps.map(&:step_id))
  end

  def schedule_params
    params.require(:schedule).permit(
      :name, schedule_steps_attributes: [:id, :step_id, :order, :_destroy]
    )
  end
end
