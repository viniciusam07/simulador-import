class AddTotalVolumeAndWeightToSimulations < ActiveRecord::Migration[7.1]
  def change
    add_column :simulations, :cbm_total, :decimal, default: 0.0, null: false
    add_column :simulations, :weight_net_total, :decimal, default: 0.0, null: false
    add_column :simulations, :weight_gross_total, :decimal, default: 0.0, null: false
  end
end
