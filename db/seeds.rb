require 'csv'

puts "Importando dados de equipments..."

# Substitua pelo caminho correto do seu arquivo CSV
csv_file_path = Rails.root.join('public', 'containers.csv')

CSV.foreach(csv_file_path, headers: true) do |row|
  Equipment.find_or_create_by!(
    name: row['Name'],                    # Nome do container
    container_type: row['Type'],          # Tipo do container
    capacity: row['Capacity (m³)'],       # Capacidade em m³
    max_weight: row['Max Weight (kg)'],   # Peso máximo em kg
    description: row['Description']       # Descrição detalhada
  )
end

puts "Equipments importados com sucesso!"
