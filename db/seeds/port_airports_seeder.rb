require 'csv'

puts "Iniciando o seed de PortAirports..."

# Caminho do arquivo CSV
file_path = Rails.root.join('db', 'seeds', 'unlocode_v3_20250110.csv')

# Verificar se o arquivo existe
unless File.exist?(file_path)
  puts "Arquivo CSV não encontrado: #{file_path}"
  exit
end

# Total de registros
total_records = CSV.read(file_path, headers: true).size
puts "Total de registros a processar: #{total_records}"

# Processar registros
CSV.foreach(file_path, headers: true).with_index do |row, index|
  # Verificar se o registro já existe
  next if PortAirport.exists?(location: row["Location"], country: row["Country"])

  # Criar o registro no banco de dados
  PortAirport.create!(
    country: row["Country"],                   # País do local
    location: row["Location"],                 # Código UN/LOCODE
    name: row["Name"],                         # Nome do porto/aeroporto
    latitude: row["Latitude"].to_f,            # Latitude
    longitude: row["Longitude"].to_f,          # Longitude
    function_array: row["FunctionArray"].split(','), # Converter string para array
    function_description: row["FunctionDescription"].split(',') # Converter string para array
  )

  # Mostrar progresso a cada 10%
  if (index + 1) % (total_records / 10) == 0
    puts "Progresso: #{((index + 1) * 100 / total_records).to_i}% concluído..."
  end
end

puts "Seed de PortAirports concluído com sucesso!"
