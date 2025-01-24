class Step < ApplicationRecord
  has_many :schedule_steps, dependent: :destroy
  has_many :schedules, through: :schedule_steps
  validates :name, presence: true
  validates :location, presence: true
  validates :default_sla, numericality: { greater_than_or_equal_to: 0 }
end
