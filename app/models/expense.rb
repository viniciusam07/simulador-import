class Expense < ApplicationRecord
  has_many :simulation_expenses

  validates :expense_name, :expense_location, presence: true
  validate :validate_fixed_or_percentage
  validates :expense_currency, presence: true, inclusion: { in: %w[BRL USD EUR], message: "deve ser uma moeda válida (BRL, USD, EUR)" }, if: :fixed_value?
  validates :calculation_base, inclusion: { in: %w[freight_cost insurance_cost total_value customs_value], message: "deve ser uma base de cálculo válida" }, if: -> { percentage.present? }

  private

  def fixed_value?
    expense_default_value.present?
  end

  def validate_fixed_or_percentage
    if expense_default_value.blank? && percentage.blank?
      errors.add(:base, "Preencha um valor fixo ou percentual.")
    elsif expense_default_value.present? && percentage.present?
      errors.add(:base, "Escolha apenas um tipo: valor fixo ou percentual.")
    end

    if percentage.present? && calculation_base.blank?
      errors.add(:calculation_base, "Base de cálculo é obrigatória para despesas percentuais.")
    end
  end
end
