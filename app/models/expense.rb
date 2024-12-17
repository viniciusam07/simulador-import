class Expense < ApplicationRecord
  has_many :simulation_expenses

  validates :expense_name, :expense_location, presence: true
  validate :validate_fixed_or_percentage

  private

  def validate_fixed_or_percentage
    if expense_default_value.blank? && percentage.blank?
      errors.add(:base, "Preencha um valor fixo ou percentual.")
    elsif expense_default_value.present? && percentage.present?
      errors.add(:base, "Escolha apenas um tipo: valor fixo ou percentual.")
    end

    if percentage.present? && calculation_base.blank?
      errors.add(:calculation_base, "Base de cálculo é obrigatória para despesas percentuais.")
    end

    if expense_default_value.present? && expense_currency.blank?
      errors.add(:expense_currency, "Moeda é obrigatória para despesas de valor fixo.")
    end
  end
end
