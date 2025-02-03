class UpdateUsersTable < ActiveRecord::Migration[7.1]
  def change
    change_table :users, bulk: true do |t|
      # Nome completo
      t.string :first_name, null: false, default: ""
      t.string :last_name, null: false, default: ""

      # Status do usuário
      t.string :status, null: false, default: "active"

      # Super Admin (controle de acesso global)
      t.boolean :super_admin, null: false, default: false

      # Última empresa acessada pelo usuário
      t.references :last_enterprise, foreign_key: { to_table: :enterprises }, index: true
    end
  end
end
