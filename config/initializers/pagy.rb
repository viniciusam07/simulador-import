# Importando os extras necessários
require 'pagy/extras/overflow' # Gerencia o comportamento de overflow de páginas
require 'pagy/extras/bootstrap' # Integração com Bootstrap

# Configurações padrão do Pagy
Pagy::DEFAULT[:items] = 10 # Número de itens por página
Pagy::DEFAULT[:size]  = [1, 4, 4, 1] # Layout da barra de navegação: links antes, ativos, depois e últimos

# Comportamento em casos de overflow
Pagy::DEFAULT[:overflow] = :last_page # Usuários são direcionados para a última página em casos de overflow
