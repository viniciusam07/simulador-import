class Equipment < ApplicationRecord
  self.table_name = 'equipments' # Garante que o model usa a tabela correta
  validates :name, :container_type, presence: true
  scope :equipments, -> { where("container_type ILIKE ?", "%equipment%") }
end
