class PublicLinkAccess < ApplicationRecord
  belongs_to :public_link

  # Validações obrigatórias
  validates :ip, :user_agent, :accessed_at, presence: true

  # Ícone baseado no navegador identificado via user_agent
  def browser_icon
    case user_agent
    when /Chrome/i
      'mdi-google-chrome'
    when /Firefox/i
      'mdi-firefox'
    when /Safari/i
      'mdi-safari'
    when /Edge/i
      'mdi-microsoft-edge'
    when /Mobile|iPhone|Android/i
      'mdi-cellphone'
    else
      'mdi-web'
    end
  end

  # Nome formatado do navegador para exibição (opcional para a timeline)
  def browser_name
    case user_agent
    when /Chrome/i
      'Google Chrome'
    when /Firefox/i
      'Mozilla Firefox'
    when /Safari/i
      'Safari'
    when /Edge/i
      'Microsoft Edge'
    when /Mobile|iPhone|Android/i
      'Dispositivo Móvel'
    else
      'Navegador Desconhecido'
    end
  end
end
