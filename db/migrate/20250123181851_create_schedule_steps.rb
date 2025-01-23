class CreateScheduleSteps < ActiveRecord::Migration[7.1]
  def change
    create_table :schedule_steps do |t|
      t.references :schedule, null: false, foreign_key: true
      t.references :step, null: false, foreign_key: true
      t.integer :order, null: false

      t.timestamps
    end
  end
end
