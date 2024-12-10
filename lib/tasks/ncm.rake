namespace :ncm do
  desc "Populate NCM codes from a CSV file"
  task populate: :environment do
    require 'csv'

    file_path = Rails.root.join('public', 'ncm_codes.csv')

    unless File.exist?(file_path)
      puts "Arquivo CSV não encontrado em #{file_path}."
      exit
    end

    puts "Iniciando a importação de NCM codes..."
    CSV.foreach(file_path, headers: true) do |row|
      code = row['code']&.strip
      description = row['description']&.strip

      if code.present? && description.present?
        NcmCode.find_or_create_by!(code: code, description: description)
      end
    rescue => e
      puts "Erro ao importar linha: #{row}. Erro: #{e.message}"
    end

    puts "Importação concluída com sucesso!"
  end
end
