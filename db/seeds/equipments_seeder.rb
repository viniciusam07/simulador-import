require 'csv'

puts "Importando dados de equipments..."

# Substitua pelo caminho correto do seu arquivo CSV
csv_file_path = Rails.root.join('db', 'seeds', 'containers.csv')

# Carregar dados do CSV
CSV.foreach(csv_file_path, headers: true) do |row|
  # Verificar se o registro já existe no banco
  next if Equipment.exists?(name: row['Name'], container_type: row['Type'])

  # Criar o registro se não existir
  Equipment.create!(
    name: row['Name'],                    # Nome do container
    container_type: row['Type'],          # Tipo do container
    capacity: row['Capacity (m³)'],       # Capacidade em m³
    max_weight: row['Max Weight (kg)'],   # Peso máximo em kg
    description: row['Description']       # Descrição detalhada
  )
end

puts "Equipments importados com sucesso!"
