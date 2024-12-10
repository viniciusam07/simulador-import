Rails.application.routes.draw do

  # Configuração de autenticação
  devise_for :users

  # Página inicial
  root to: "pages#home"

  # Verificação de saúde da aplicação
  get "up" => "rails/health#show", as: :rails_health_check

  # Rotas para Simulações
  resources :simulations, only: [:index, :new, :create, :show]
  get 'exchange_rate', to: 'simulations#exchange_rate'

  # Rotas para Despesas
  resources :expenses, only: [:index, :new, :create, :edit, :update, :destroy, :show]

  # Rotas para Fornecedores
  resources :suppliers

  # Rotas para Produtos
  resources :products do
    resources :quotations, only: [:new, :create, :edit, :update, :destroy]
  end
end
