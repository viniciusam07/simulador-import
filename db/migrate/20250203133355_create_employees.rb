class CreateEmployees < ActiveRecord::Migration[7.1]
  def change
    create_table :employees do |t|
      t.references :user, null: false, foreign_key: true
      t.references :enterprise, null: false, foreign_key: true
      t.integer :role, null: false, default: 2 # Enum: 0 = Owner, 1 = Admin, 2 = Member

      t.timestamps
    end

    add_index :employees, [:user_id, :enterprise_id], unique: true
  end
end
