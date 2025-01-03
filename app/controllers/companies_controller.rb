class CompaniesController < ApplicationController
  before_action :set_company, only: [:show, :edit, :update, :destroy]

  # Lista todas as empresas
  def index
    @companies = Company.all
  end

  # Exibe os detalhes de uma empresa
  def show
    # @company já é configurado pelo método set_company
  end

  # Formulário para criar uma nova empresa
  def new
    @company = Company.new
  end

  # Cria uma nova empresa
  def create
    @company = Company.new(company_params)
    if @company.save
      redirect_to companies_path, notice: 'Empresa cadastrada com sucesso!'
    else
      render :new, status: :unprocessable_entity
    end
  end

  # Formulário para editar uma empresa
  def edit
    # @company já é configurado pelo método set_company
  end

  # Atualiza uma empresa existente
  def update
    if @company.update(company_params)
      redirect_to companies_path, notice: 'Empresa atualizada com sucesso!'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # Exclui uma empresa
  def destroy
    @company.destroy
    redirect_to companies_path, notice: 'Empresa deletada com sucesso!'
  end

  private

  # Configura a variável @company para as ações show, edit, update e destroy
  def set_company
    @company = Company.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to companies_path, alert: 'Empresa não encontrada.'
  end

  # Permite apenas os parâmetros seguros para criação/atualização de empresas
  def company_params
    params.require(:company).permit(:name, :cnpj, :corporate_name, :zip_code, :address, :state, :city, :segment, :company_type, :tax_regime)
  end
end
