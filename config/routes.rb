Rails.application.routes.draw do
  # Configuração de autenticação
  devise_for :users

  # Página inicial
  root to: "pages#home"

  # Página de Cronogramas
  get 'cronogramas', to: 'pages#cronogramas', as: 'cronogramas'

  # Verificação de saúde da aplicação
  get "up" => "rails/health#show", as: :rails_health_check

  # Rotas para Simulações
  resources :simulations, only: [:index, :new, :create, :show, :edit, :update] do
    member do
      get :generate_pdf
    end
    resources :simulation_quotations, only: [:create, :destroy], shallow: true
    resource :simulation_schedule, only: [:new, :create, :edit, :update]
  end
  get 'exchange_rate', to: 'simulations#exchange_rate'

  # Rotas para Despesas
  resources :expenses, only: [:index, :new, :create, :edit, :update, :destroy, :show]

  # Rotas para Fornecedores
  resources :suppliers

  # Rotas para Produtos
  resources :products do
    resources :quotations, only: [:new, :create, :edit, :update, :destroy] do
      member do
        get :unit_price # Adicionado para carregar preço unitário
      end
    end
  end

  # Rotas para Cotações
  resources :quotations, only: [:show] # Adicionado para carregar cotação via JSON

  # Rotas para NCMs
  resources :ncm_codes, only: [] do
    collection do
      get :autocomplete, defaults: { format: :json }
    end
  end

  # Rotas para Companies
  resources :companies

  # Rotas para Equipamentos
  resources :equipments, only: [:index]

  # Rotas para Steps (Schedules)
  resources :steps, only: [:index, :new, :create, :edit, :update, :destroy]

  # Rotas para Schedules
  resources :schedules, only: [:index, :new, :create, :edit, :update, :destroy] do
    get :details, on: :member
    member do
      post :add_step
      delete :remove_step
    end
  end
end
