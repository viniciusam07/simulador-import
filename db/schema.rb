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

ActiveRecord::Schema[7.1].define(version: 2025_01_06_141359) do
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
  end

  create_table "ncm_codes", force: :cascade do |t|
    t.string "code"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "products", force: :cascade do |t|
    t.string "product_name"
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
    t.index ["product_id"], name: "index_quotations_on_product_id"
    t.index ["supplier_id"], name: "index_quotations_on_supplier_id"
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
    t.index ["expense_id"], name: "index_simulation_expenses_on_expense_id"
    t.index ["simulation_id"], name: "index_simulation_expenses_on_simulation_id"
  end

  create_table "simulation_quotations", force: :cascade do |t|
    t.bigint "simulation_id", null: false
    t.bigint "quotation_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "quantity"
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
    t.decimal "custom_price", precision: 10, scale: 2
    t.index ["quotation_id"], name: "index_simulation_quotations_on_quotation_id"
    t.index ["simulation_id"], name: "index_simulation_quotations_on_simulation_id"
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
    t.index ["company_id"], name: "index_simulations_on_company_id"
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
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "quotations", "products"
  add_foreign_key "quotations", "suppliers"
  add_foreign_key "simulation_expenses", "expenses"
  add_foreign_key "simulation_expenses", "simulations"
  add_foreign_key "simulation_quotations", "quotations"
  add_foreign_key "simulation_quotations", "simulations"
  add_foreign_key "simulation_taxes", "simulations"
  add_foreign_key "simulation_taxes", "taxes"
  add_foreign_key "simulations", "companies"
  add_foreign_key "simulations", "equipments"
  add_foreign_key "tax_rates", "taxes"
end
