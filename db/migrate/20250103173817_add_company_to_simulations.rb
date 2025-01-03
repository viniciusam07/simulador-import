class AddCompanyToSimulations < ActiveRecord::Migration[7.1]
  def change
    add_reference :simulations, :company, null: false, foreign_key: true
  end
end
