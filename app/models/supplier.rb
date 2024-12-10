class Supplier < ApplicationRecord
  has_many :quotations, dependent: :destroy
  # Validações para garantir que os campos principais estejam sempre presentes
  validates :corporate_name, :trade_name, :country, presence: true
end
