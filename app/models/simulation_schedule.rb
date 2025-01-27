class SimulationSchedule < ApplicationRecord
  belongs_to :simulation
  belongs_to :schedule, optional: true # Permite associar um cronograma existente

  validates :schedule_name, :start_date, presence: true
  validate :validate_steps_dates

  before_validation :parse_steps
  before_save :calculate_end_dates

  # Inclui métodos para recalcular datas conforme alterações no SLA
  def steps_with_defaults
    current_start_date = start_date

    steps.map do |step|
      step_start_date = step["start_date"] || current_start_date
      step_sla = step["sla"].to_i
      step_end_date = step_start_date + step_sla.days

      current_start_date = step_end_date

      {
        name: step["name"],
        start_date: step_start_date,
        end_date: step_end_date,
        sla: step_sla
      }
    end
  end

  private

  def parse_steps
    if steps.is_a?(Hash)
      self.steps = steps.values
    elsif steps.is_a?(String)
      self.steps = JSON.parse(steps)
    end
  rescue JSON::ParserError
    errors.add(:steps, "formato inválido")
  end

  def validate_steps_dates
    steps.each do |step|
      start_date = step["start_date"].to_date if step["start_date"].present?
      end_date = step["end_date"].to_date if step["end_date"].present?

      if start_date && end_date && end_date < start_date
        errors.add(:steps, "A data de fim não pode ser anterior à data de início para a etapa: #{step['name']}")
      end
    end
  end

  def calculate_end_dates
    current_start_date = start_date
    steps.each do |step|
      step["start_date"] ||= current_start_date
      step["end_date"] ||= step["start_date"] + step["sla"].to_i.days
      current_start_date = step["end_date"]
    end
  end
end
