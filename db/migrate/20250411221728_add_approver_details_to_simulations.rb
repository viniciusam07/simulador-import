class AddApproverDetailsToSimulations < ActiveRecord::Migration[7.1]
  def change
    add_column :simulations, :approver_name, :string
    add_column :simulations, :approver_email, :string
  end
end
