Rails.application.routes.draw do
  # Configuração do Devise
  devise_for :users

  # Página inicial para usuários NÃO autenticados (Login)
  devise_scope :user do
    unauthenticated do
      root to: "devise/sessions#new", as: :unauthenticated_root
    end

    # Página inicial para usuários AUTENTICADOS (Home)
    authenticated :user do
      root to: "pages#home", as: :authenticated_root
    end
  end

  # Página Home
  get 'home', to: 'pages#home', as: 'home'

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
        get :unit_price
      end
    end
  end

  # Rotas para Cotações
  resources :quotations, only: [:show]

  # Rotas para NCMs
  resources :ncm_codes, only: [] do
    collection do
      get :autocomplete, defaults: { format: :json }
    end
  end

  # Rotas para Empresas
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

  # Rotas para Empresas (`Enterprises`) e Funcionários (`Employees`)
  resources :enterprises do
    resources :employees, only: [:index, :new, :create, :edit, :update, :destroy]
  end
end
