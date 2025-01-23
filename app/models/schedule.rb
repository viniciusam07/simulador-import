class Schedule < ApplicationRecord
  has_many :schedule_steps, dependent: :destroy
  has_many :steps, through: :schedule_steps

  validates :name, presence: true

  accepts_nested_attributes_for :schedule_steps, allow_destroy: true
end
