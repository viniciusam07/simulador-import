class AddScheduleIdToSimulationSchedules < ActiveRecord::Migration[7.1]
  def change
    add_column :simulation_schedules, :schedule_id, :integer
  end
end
