class Schedule < ApplicationRecord
  has_many :schedule_steps, dependent: :destroy, inverse_of: :schedule
  has_many :steps, through: :schedule_steps

  validates :name, presence: true

  accepts_nested_attributes_for :schedule_steps, allow_destroy: true

  after_save :recalculate_order

  private

  def recalculate_order
    schedule_steps.order(:created_at).each_with_index do |schedule_step, index|
      schedule_step.update(order: index + 1)
    end
  end
end
