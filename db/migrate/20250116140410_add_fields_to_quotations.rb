class AddFieldsToQuotations < ActiveRecord::Migration[7.1]
  def change
    add_column :quotations, :sku_supplier_id, :string
    add_column :quotations, :total_cbm, :decimal, precision: 10, scale: 2
    add_column :quotations, :cargo_type, :string
    add_column :quotations, :total_gross_weight, :decimal, precision: 10, scale: 2
    add_column :quotations, :total_net_weight, :decimal, precision: 10, scale: 2
  end
end
