class Company < ApplicationRecord
  # Constantes para campos de seleção
  SEGMENTS = ['Logística', 'Moda', 'E-commerce', 'Tecnologia', 'Outros']
  COMPANY_TYPES = ['Indústria', 'Prestador de Serviço', 'Varejista', 'Atacadista', 'Distribuidora']
  TAX_REGIMES = ['Lucro Real', 'Lucro Presumido', 'Simples Nacional']

  # Validações
  validates :name, :cnpj, :corporate_name, presence: true
  validates :cnpj, uniqueness: true
  validates :segment, inclusion: { in: SEGMENTS, message: 'Segmento inválido' }, allow_blank: true
  validates :company_type, inclusion: { in: COMPANY_TYPES, message: 'Tipo de empresa inválido' }, allow_blank: true
  validates :tax_regime, inclusion: { in: TAX_REGIMES, message: 'Regime tributário inválido' }, allow_blank: true
  validate :valid_cnpj_format

  # Callback para buscar endereço pelo CEP antes de validar
  before_validation :fetch_address_from_zip_code, if: :zip_code_changed?
  before_validation :format_cnpj

  private

  def fetch_address_from_zip_code
    return unless zip_code.present?

    zip_code_info = BrZipCode.get(zip_code.delete('-'))

    # Verifica se o retorno é um Hash válido
    if zip_code_info.is_a?(Hash)
      self.address = zip_code_info[:street] || zip_code_info['street']
      self.state = zip_code_info[:state] || zip_code_info['state']
      self.city = zip_code_info[:city] || zip_code_info['city']
    else
      errors.add(:zip_code, 'não pôde ser encontrado. Verifique o CEP informado.')
    end
  end

  # Formata o CNPJ antes de salvar
  def format_cnpj
    return unless cnpj.present?

    cnpj_object = CNPJ.new(cnpj)
    self.cnpj = cnpj_object.formatted if cnpj_object.valid?
  end

  # Valida o CNPJ
  def valid_cnpj_format
    errors.add(:cnpj, 'é inválido') unless CNPJ.valid?(cnpj)
  end
end
