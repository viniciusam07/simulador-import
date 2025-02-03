class Employee < ApplicationRecord
  # Definição de papéis via enum
  enum role: { owner: 0, admin: 1, member: 2 }

  # Relacionamentos
  belongs_to :user
  belongs_to :enterprise

  # Validações
  validates :role, presence: true
end
