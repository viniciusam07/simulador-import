# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
Expense.create!(
  expense_name: 'AFRMM',
  expense_description: 'Adicional de Frete para Renovação da Marinha Mercante',
  expense_default_value: 0.0, # Inclua um valor padrão, mesmo que a despesa seja percentual
  percentage: 8.0, # Campo para percentual da AFRMM
  expense_currency: 'BRL',
  expense_location: 'Origem'
)
