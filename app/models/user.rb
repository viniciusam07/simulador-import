class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable,  and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable
  # Relacionamento: Um usuário pode ter UM Employee, e estar vinculado a UMA empresa através do Employee
  has_one :employee, dependent: :destroy
  has_one :enterprise, through: :employee

  # Relacionamento: Se for criador de uma empresa, pode aparecer aqui
  has_many :enterprises, dependent: :destroy

  # Validações
  validates :first_name, :last_name, presence: true
  validates :status, inclusion: { in: %w[active inactive suspended] }

  # Métodos auxiliares

  # Retorna o nome completo do usuário
  def full_name
    "#{first_name} #{last_name}"
  end

  # Verifica se o usuário está ativo
  def active?
    status == "active"
  end

  # Verifica se é Super Admin
  def super_admin?
    super_admin
  end

  # Obtém o papel do usuário na empresa, se existir
  def role
    employee&.role || "Nenhum"
  end
end
