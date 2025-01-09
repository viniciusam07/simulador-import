require 'json'

puts "Iniciando o seed de PortAirports..."

# Caminho do arquivo JSON
file_path = Rails.root.join('db', 'seeds', 'unlocode_v2_20250109.json')

# Verificar se o arquivo existe
unless File.exist?(file_path)
  puts "Arquivo JSON não encontrado: #{file_path}"
  exit
end

# Carregar o arquivo JSON
data = JSON.parse(File.read(file_path))

# Total de registros
total_records = data.size
puts "Total de registros a processar: #{total_records}"

# Processar registros
data.each_with_index do |record, index|
  # Criar o registro no banco de dados
  PortAirport.create!(
    country: record["Country"],
    location: record["Location"],
    name: record["Name"],
    name_without_diacritics: record["NameWoDiacritics"],
    status: record["Status"],
    iata: record["IATA"],
    latitude: record["Latitude"],
    longitude: record["Longitude"],
    function_array: record["FunctionArray"],
    function_description: record["FunctionDescription"]
  )

  # Mostrar progresso a cada 10%
  if (index + 1) % (total_records / 10) == 0
    puts "Progresso: #{((index + 1) * 100 / total_records).to_i}% concluído..."
  end
end

puts "Seed concluído com sucesso!"
