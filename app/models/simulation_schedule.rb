class SimulationSchedule < ApplicationRecord
  belongs_to :simulation

  validates :schedule_name, :start_date, presence: true

  # Métodos para lidar com as etapas
  def steps_with_defaults
    current_start_date = start_date

    steps.map do |step|
      step_start_date = step["start_date"] || current_start_date
      step_sla = step["sla"] || 0
      step_end_date = step["end_date"] || (step_start_date + step_sla.days)

      current_start_date = step_end_date

      {
        name: step["name"],
        start_date: step_start_date,
        end_date: step_end_date,
        sla: step_sla
      }
    end
  end
end
