class PagesController < ApplicationController
  # Permite que usuários não autenticados acessem a página inicial
  skip_before_action :authenticate_user!, only: [:home]

  def home
  end

  def cronogramas
  end
end
