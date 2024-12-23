class SimulationQuotation < ApplicationRecord
  belongs_to :simulation
  belongs_to :quotation

  # Validações
  validates :quotation_id, uniqueness: { scope: :simulation_id, message: "já está adicionada à simulação" }
  validates :quantity, numericality: { greater_than_or_equal_to: 0 }
  validates :custom_price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  # Callbacks
  before_save :set_default_custom_price

  # Métodos Públicos

  # Calcula o valor total da simulation quotation
  def total_value
    (custom_price || quotation&.price || 0) * quantity.to_f
  end

  private

  # Define o preço customizado padrão como o preço da quotation, caso não esteja definido
  def set_default_custom_price
    self.custom_price ||= quotation&.price if quotation.present?
  end
end
