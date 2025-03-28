# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2025_03_28_184636) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "companies", force: :cascade do |t|
    t.string "name", null: false
    t.string "cnpj", null: false
    t.string "corporate_name", null: false
    t.string "zip_code"
    t.string "address"
    t.string "state"
    t.string "city"
    t.string "segment"
    t.string "company_type"
    t.string "tax_regime"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cnpj"], name: "index_companies_on_cnpj", unique: true
  end

  create_table "employees", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "enterprise_id", null: false
    t.integer "role", default: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["enterprise_id"], name: "index_employees_on_enterprise_id"
    t.index ["user_id", "enterprise_id"], name: "index_employees_on_user_id_and_enterprise_id", unique: true
    t.index ["user_id"], name: "index_employees_on_user_id"
  end

  create_table "enterprises", force: :cascade do |t|
    t.string "name", null: false
    t.string "cnpj", null: false
    t.string "phone"
    t.string "contact"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cnpj"], name: "index_enterprises_on_cnpj", unique: true
    t.index ["user_id"], name: "index_enterprises_on_user_id"
  end

  create_table "equipments", force: :cascade do |t|
    t.string "name", null: false
    t.string "container_type", null: false
    t.float "capacity"
    t.integer "max_weight"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "expenses", force: :cascade do |t|
    t.string "expense_name", null: false
    t.text "expense_description"
    t.decimal "expense_default_value", precision: 10, scale: 2
    t.string "expense_currency", null: false
    t.string "expense_location", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "percentage"
    t.string "type_of_expense"
    t.string "calculation_base"
    t.integer "tax_calculation_impact", default: 0, null: false
  end

  create_table "ncm_codes", force: :cascade do |t|
    t.string "code"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "port_airports", force: :cascade do |t|
    t.string "country", null: false
    t.string "location", null: false
    t.string "name", null: false
    t.decimal "latitude", precision: 10, scale: 6
    t.decimal "longitude", precision: 10, scale: 6
    t.jsonb "function_array", default: []
    t.jsonb "function_description", default: []
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["location"], name: "index_port_airports_on_location"
  end

  create_table "products", force: :cascade do |t|
    t.string "product_name"
    t.string "supplier_code"
    t.string "hs_code"
    t.string "ncm"
    t.string "unit_of_measure"
    t.integer "quantity_per_box"
    t.decimal "unit_net_weight"
    t.decimal "unit_price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "quotations", force: :cascade do |t|
    t.bigint "product_id", null: false
    t.bigint "supplier_id", null: false
    t.decimal "price", precision: 10, scale: 2, null: false
    t.string "currency", null: false
    t.date "validity", null: false
    t.integer "moq", null: false
    t.string "payment_terms", null: false
    t.integer "lead_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "sku_supplier_id"
    t.decimal "total_cbm", precision: 10, scale: 2
    t.string "cargo_type"
    t.decimal "total_gross_weight", precision: 10, scale: 2
    t.decimal "total_net_weight", precision: 10, scale: 2
    t.text "observations"
    t.string "product_quotation_description"
    t.index ["product_id"], name: "index_quotations_on_product_id"
    t.index ["supplier_id"], name: "index_quotations_on_supplier_id"
  end

  create_table "schedule_steps", force: :cascade do |t|
    t.bigint "schedule_id", null: false
    t.bigint "step_id", null: false
    t.integer "order", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["schedule_id"], name: "index_schedule_steps_on_schedule_id"
    t.index ["step_id"], name: "index_schedule_steps_on_step_id"
  end

  create_table "schedules", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "simulation_expenses", force: :cascade do |t|
    t.integer "simulation_id", null: false
    t.integer "expense_id"
    t.string "expense_custom_name"
    t.decimal "expense_custom_value", precision: 10, scale: 2
    t.string "expense_currency", null: false
    t.string "expense_location", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "tax_calculation_impact", default: 0, null: false
    t.index ["expense_id"], name: "index_simulation_expenses_on_expense_id"
    t.index ["simulation_id"], name: "index_simulation_expenses_on_simulation_id"
  end

  create_table "simulation_products", force: :cascade do |t|
    t.bigint "simulation_id", null: false
    t.bigint "product_id", null: false
    t.integer "product_quantity"
    t.decimal "custom_unit_price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_simulation_products_on_product_id"
    t.index ["simulation_id"], name: "index_simulation_products_on_simulation_id"
  end

  create_table "simulation_quotations", force: :cascade do |t|
    t.bigint "simulation_id", null: false
    t.bigint "quotation_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "quantity"
    t.decimal "custom_price", precision: 10, scale: 2
    t.decimal "total_value"
    t.decimal "aliquota_ii", precision: 5, scale: 2
    t.decimal "aliquota_ipi", precision: 5, scale: 2
    t.decimal "aliquota_pis", precision: 5, scale: 2
    t.decimal "aliquota_cofins", precision: 5, scale: 2
    t.decimal "aliquota_icms", precision: 5, scale: 2
    t.decimal "tributo_ii", precision: 10, scale: 2
    t.decimal "tributo_ipi", precision: 10, scale: 2
    t.decimal "tributo_pis", precision: 10, scale: 2
    t.decimal "tributo_cofins", precision: 10, scale: 2
    t.decimal "tributo_icms", precision: 10, scale: 2
    t.decimal "customs_total_value"
    t.decimal "customs_unit_value", precision: 10, scale: 2
    t.decimal "freight_allocated", precision: 10, scale: 2
    t.decimal "insurance_allocated", precision: 10, scale: 2
    t.index ["quotation_id"], name: "index_simulation_quotations_on_quotation_id"
    t.index ["simulation_id"], name: "index_simulation_quotations_on_simulation_id"
  end

  create_table "simulation_schedules", force: :cascade do |t|
    t.bigint "simulation_id", null: false
    t.string "schedule_name", null: false
    t.date "start_date", null: false
    t.jsonb "steps", default: []
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "schedule_id"
    t.index ["simulation_id"], name: "index_simulation_schedules_on_simulation_id"
  end

  create_table "simulation_taxes", force: :cascade do |t|
    t.bigint "simulation_id", null: false
    t.bigint "tax_id", null: false
    t.decimal "calculated_value", precision: 10, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["simulation_id"], name: "index_simulation_taxes_on_simulation_id"
    t.index ["tax_id"], name: "index_simulation_taxes_on_tax_id"
  end

  create_table "simulations", force: :cascade do |t|
    t.string "origin_country"
    t.decimal "total_value"
    t.string "incoterm"
    t.string "modal"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "aliquota_ii", precision: 5, scale: 2
    t.decimal "tributo_ii", precision: 10, scale: 2
    t.decimal "aliquota_ipi", precision: 5, scale: 2
    t.decimal "tributo_ipi", precision: 10, scale: 2
    t.decimal "aliquota_pis", precision: 5, scale: 2
    t.decimal "tributo_pis", precision: 10, scale: 2
    t.decimal "aliquota_cofins", precision: 5, scale: 2
    t.decimal "tributo_cofins", precision: 10, scale: 2
    t.decimal "aliquota_icms", precision: 5, scale: 2
    t.decimal "tributo_icms", precision: 10, scale: 2
    t.string "currency"
    t.decimal "freight_cost"
    t.decimal "insurance_cost"
    t.integer "user_id"
    t.decimal "customs_value"
    t.decimal "exchange_rate"
    t.decimal "total_customs_value_brl"
    t.decimal "freight_cost_brl", precision: 10, scale: 2
    t.decimal "insurance_cost_brl", precision: 10, scale: 2
    t.decimal "total_value_brl", precision: 10, scale: 2
    t.string "destination_state"
    t.string "origin_port"
    t.string "destination_port"
    t.string "origin_airport"
    t.string "destination_airport"
    t.decimal "import_factor", precision: 10, scale: 2
    t.string "cfop_code"
    t.string "cfop_description"
    t.bigint "company_id", null: false
    t.integer "equipment_id"
    t.integer "equipment_quantity"
    t.decimal "cbm_total", default: "0.0", null: false
    t.decimal "weight_net_total", default: "0.0", null: false
    t.decimal "weight_gross_total", default: "0.0", null: false
    t.string "cargo_type"
    t.text "observations"
    t.string "status", default: "draft", null: false
    t.decimal "exchange_rate_goods", precision: 10, scale: 4
    t.decimal "exchange_rate_freight", precision: 10, scale: 4
    t.decimal "exchange_rate_insurance", precision: 10, scale: 4
    t.string "currency_freight"
    t.string "currency_insurance"
    t.index ["company_id"], name: "index_simulations_on_company_id"
  end

  create_table "steps", force: :cascade do |t|
    t.string "name", null: false
    t.string "location", null: false
    t.integer "default_sla", null: false
    t.string "icon"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "supplier_contacts", force: :cascade do |t|
    t.bigint "supplier_id", null: false
    t.string "contact_name"
    t.string "email"
    t.string "phone"
    t.string "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["supplier_id"], name: "index_supplier_contacts_on_supplier_id"
  end

  create_table "suppliers", force: :cascade do |t|
    t.string "corporate_name"
    t.string "trade_name"
    t.string "country"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tax_rates", force: :cascade do |t|
    t.bigint "tax_id", null: false
    t.string "ncm", null: false
    t.decimal "rate", precision: 5, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tax_id"], name: "index_tax_rates_on_tax_id"
  end

  create_table "taxes", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name", default: "", null: false
    t.string "last_name", default: "", null: false
    t.string "status", default: "active", null: false
    t.boolean "super_admin", default: false, null: false
    t.bigint "last_enterprise_id"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["last_enterprise_id"], name: "index_users_on_last_enterprise_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "versions", force: :cascade do |t|
    t.string "whodunnit"
    t.datetime "created_at"
    t.bigint "item_id", null: false
    t.string "item_type", null: false
    t.string "event", null: false
    t.text "object"
    t.text "object_changes"
    t.integer "user_id"
    t.integer "simulation_id"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
    t.index ["simulation_id"], name: "index_versions_on_simulation_id"
    t.index ["user_id"], name: "index_versions_on_user_id"
  end

  add_foreign_key "employees", "enterprises"
  add_foreign_key "employees", "users"
  add_foreign_key "enterprises", "users"
  add_foreign_key "quotations", "products"
  add_foreign_key "quotations", "suppliers"
  add_foreign_key "schedule_steps", "schedules"
  add_foreign_key "schedule_steps", "steps"
  add_foreign_key "simulation_expenses", "expenses"
  add_foreign_key "simulation_expenses", "simulations"
  add_foreign_key "simulation_products", "products"
  add_foreign_key "simulation_products", "simulations"
  add_foreign_key "simulation_quotations", "quotations"
  add_foreign_key "simulation_quotations", "simulations"
  add_foreign_key "simulation_schedules", "simulations"
  add_foreign_key "simulation_taxes", "simulations"
  add_foreign_key "simulation_taxes", "taxes"
  add_foreign_key "simulations", "companies"
  add_foreign_key "simulations", "equipments"
  add_foreign_key "supplier_contacts", "suppliers"
  add_foreign_key "tax_rates", "taxes"
  add_foreign_key "users", "enterprises", column: "last_enterprise_id"
end
