class ScheduleStep < ApplicationRecord
  belongs_to :schedule
  belongs_to :step

  validates :order, presence: true
end
