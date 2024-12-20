class Quotation < ApplicationRecord
  belongs_to :product
  belongs_to :supplier

  validates :price, :currency, :validity, :moq, presence: true
  validates :moq, numericality: { greater_than: 0 }

  PAYMENT_TERMS = [
    "30% antecipado, 70% no embarque",
    "50% antecipado, 50% na entrega",
    "100% antecipado",
    "Carta de crédito (L/C)",
    "Pagamento à vista (T/T)"
  ]

  def display_name
    "#{product.product_name} - #{supplier.trade_name} - #{price} #{currency}"
  end
end
