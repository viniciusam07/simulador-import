class AddObservationsAndProductQuotationDescriptionToQuotations < ActiveRecord::Migration[7.1]
  def change
    add_column :quotations, :observations, :text
    add_column :quotations, :product_quotation_description, :string
  end
end
