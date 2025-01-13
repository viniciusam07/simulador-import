class AddSimulationIdToVersions < ActiveRecord::Migration[7.1]
  def change
    add_column :versions, :simulation_id, :integer
    add_index :versions, :simulation_id
  end
end
