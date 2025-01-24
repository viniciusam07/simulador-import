class ScheduleStep < ApplicationRecord
  belongs_to :schedule
  belongs_to :step

  validates :step_id, presence: true, uniqueness: { scope: :schedule_id, message: "já está associado a este cronograma" }
  validates :order, presence: true, numericality: { only_integer: true, greater_than: 0 }
end
