class SimulationSchedule < ApplicationRecord
  belongs_to :simulation

  validates :schedule_name, :start_date, presence: true
  validate :validate_steps_dates

  before_validation :parse_steps

  before_save :calculate_end_dates

  # Métodos para lidar com as etapas
  def steps_with_defaults
    Rails.logger.debug "Calculando steps_with_defaults para: #{steps.inspect}"
    current_start_date = start_date

    steps.map do |step|
      Rails.logger.debug "Processando etapa: #{step.inspect}"
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

  private

  # Garante que steps seja um array de hashes
  def parse_steps
    Rails.logger.debug "Parsing steps: #{steps.inspect}"

    # Converte hash de hashes para array de hashes
    if steps.is_a?(Hash)
      self.steps = steps.values
    elsif steps.is_a?(String)
      self.steps = JSON.parse(steps)
    end
  rescue JSON::ParserError
    Rails.logger.error "Erro ao parsear steps: #{steps.inspect}"
    errors.add(:steps, "formato inválido")
  end


  # Validação para garantir que a data de fim de uma etapa não seja anterior à data de início
  def validate_steps_dates
    Rails.logger.debug "Validando datas das etapas para: #{steps.inspect}"
    steps.each do |step|
      Rails.logger.debug "Validando etapa: #{step.inspect}"
      start_date = step["start_date"].to_date if step["start_date"].present?
      end_date = step["end_date"].to_date if step["end_date"].present?

      if start_date.present? && end_date.present? && end_date < start_date
        Rails.logger.warn "Data de fim anterior à data de início: #{step.inspect}"
        errors.add(:steps, "A data de fim não pode ser anterior à data de início para a etapa: #{step['name']}")
      end
    end
  end

  # Método para calcular as datas de fim das etapas automaticamente
  def calculate_end_dates
    Rails.logger.debug "Calculando datas de fim para steps: #{steps.inspect}"
    current_start_date = start_date
    steps.each do |step|
      Rails.logger.debug "Calculando para etapa: #{step.inspect}"
      step["start_date"] ||= current_start_date
      step["end_date"] ||= step["start_date"] + step["sla"].days if step["sla"]
      current_start_date = step["end_date"]
    end
  end
end
