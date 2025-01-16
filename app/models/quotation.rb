class Quotation < ApplicationRecord
  belongs_to :product
  belongs_to :supplier

  CARGO_TYPES = [
    "Box",
    "Bigbags",
    "Sacks",
    "Barrels",
    "Rolls"
  ]

  PAYMENT_TERMS = [
    "30% antecipado, 70% no embarque",
    "50% antecipado, 50% na entrega",
    "100% antecipado",
    "Carta de crédito (L/C)",
    "Pagamento à vista (T/T)"
  ]

  validates :price, :currency, :validity, :moq, presence: true
  validates :total_cbm, :total_gross_weight, :total_net_weight, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :cargo_type, inclusion: { in: CARGO_TYPES }, allow_blank: true
  validates :sku_supplier_id, presence: true, format: { with: /\A[\w\-.]+\z/, message: 'formato inválido' }
  validates :product_quotation_description, length: { maximum: 255 }, allow_blank: true


  def display_name
    "#{product.product_name} - #{supplier.trade_name} - #{price} #{currency}"
  end
end
