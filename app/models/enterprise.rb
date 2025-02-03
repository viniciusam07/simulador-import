class Enterprise < ApplicationRecord
  # Criador da empresa
  belongs_to :user

  # Relacionamentos
  has_many :employees, dependent: :destroy
  has_many :users, through: :employees

  # Validações
  validates :name, :cnpj, presence: true, uniqueness: true

  # Métodos auxiliares

  # Retorna o dono da empresa (se existir um employee com role 'owner')
  def owner
    employees.find_by(role: "owner")&.user || user # Se não tiver dono via Employee, retorna o criador
  end

  # Lista administradores da empresa
  def admins
    employees.where(role: "admin").map(&:user)
  end

  # Lista membros da empresa
  def members
    employees.where(role: "member").map(&:user)
  end
end
