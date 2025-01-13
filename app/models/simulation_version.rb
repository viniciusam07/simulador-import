class SimulationVersion < PaperTrail::Version
  self.table_name = 'versions' # Usa a tabela padrão de versões
  belongs_to :simulation, optional: true # Adiciona associação, se necessário
end
