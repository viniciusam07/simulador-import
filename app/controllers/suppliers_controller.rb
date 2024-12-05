class SuppliersController < ApplicationController
  before_action :set_supplier, only: %i[show edit update destroy]

  # Lista todos os fornecedores
  def index
    @suppliers = Supplier.all
  end

  # Exibe detalhes de um fornecedor específico
  def show; end

  # Inicializa um novo fornecedor
  def new
    @supplier = Supplier.new
  end

  # Cria um fornecedor e salva no banco
  def create
    @supplier = Supplier.new(supplier_params)
    if @supplier.save
      redirect_to supplier_path(@supplier), notice: 'Fornecedor criado com sucesso.'
    else
      render :new
    end
  end

  # Edita um fornecedor existente
  def edit; end

  # Atualiza um fornecedor no banco
  def update
    if @supplier.update(supplier_params)
      redirect_to @supplier, notice: 'Fornecedor atualizado com sucesso.'
    else
      render :edit
    end
  end

  # Exclui um fornecedor do banco
  def destroy
    @supplier.destroy
    redirect_to suppliers_path, notice: 'Fornecedor excluído com sucesso.'
  end

  private

  # Define o fornecedor pelo ID fornecido
  def set_supplier
    @supplier = Supplier.find(params[:id])
  end

  # Define os parâmetros permitidos para um fornecedor
  def supplier_params
    params.require(:supplier).permit(:corporate_name, :trade_name, :country)
  end
end
