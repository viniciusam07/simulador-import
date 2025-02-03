class EnterprisesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_enterprise, only: %i[show edit update destroy]
  before_action :authorize_admin!, only: %i[edit update destroy]

  def index
    # Super Admins veem todas as empresas, usuários comuns só veem as suas
    @enterprises = current_user.super_admin? ? Enterprise.all : current_user.enterprises
  end

  def show
  end

  def new
    @enterprise = Enterprise.new
  end

  def create
    @enterprise = Enterprise.new(enterprise_params)
    @enterprise.user = current_user # Define o criador da empresa

    if @enterprise.save
      # O criador da empresa já entra como "owner"
      Employee.create!(user: current_user, enterprise: @enterprise, role: "owner")
      redirect_to @enterprise, notice: "Empresa criada com sucesso!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @enterprise.update(enterprise_params)
      redirect_to @enterprise, notice: "Empresa atualizada com sucesso!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @enterprise.destroy
    redirect_to enterprises_path, notice: "Empresa excluída com sucesso!"
  end

  private

  def set_enterprise
    @enterprise = Enterprise.find(params[:id])
  end

  def authorize_admin!
    unless current_user.super_admin? || current_user.employee&.owner? || current_user.employee&.admin?
      redirect_to enterprises_path, alert: "Você não tem permissão para essa ação."
    end
  end

  def enterprise_params
    params.require(:enterprise).permit(:name, :cnpj, :phone, :contact)
  end
end
