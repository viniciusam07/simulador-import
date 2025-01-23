class CreateSimulationSchedules < ActiveRecord::Migration[7.1]
  def change
    create_table :simulation_schedules do |t|
      t.references :simulation, null: false, foreign_key: true  # Associação com simulações
      t.string :schedule_name, null: false                     # Nome do cronograma
      t.date :start_date, null: false                          # Data de início do cronograma
      t.jsonb :steps, default: []                              # Etapas do cronograma armazenadas como JSON

      t.timestamps
    end
  end
end
