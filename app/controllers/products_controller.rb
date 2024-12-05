class ProductsController < ApplicationController
  before_action :set_product, only: %i[show edit update destroy]

  # Lista todos os produtos
  def index
    @products = Product.all
  end

  # Inicializa um novo produto
  def new
    @product = Product.new
  end

  # Cria um produto e salva no banco
  def create
    @product = Product.new(product_params)
    if @product.save
      redirect_to @product, notice: 'Produto criado com sucesso.'
    else
      render :new
    end
  end

  # Edita um produto existente
  def edit; end

  # Atualiza um produto no banco
  def update
    if @product.update(product_params)
      redirect_to @product, notice: 'Produto atualizado com sucesso.'
    else
      render :edit
    end
  end

  # Exclui um produto do banco
  def destroy
    @product.destroy
    redirect_to products_path, notice: 'Produto excluído com sucesso.'
  end

  private

  # Define o produto pelo ID fornecido
  def set_product
    @product = Product.find(params[:id])
  end

  # Define os parâmetros permitidos para um produto
  def product_params
    params.require(:product).permit(:product_name, :hs_code, :ncm, :unit_of_measure, :quantity_per_box, :unit_net_weight, :unit_price)
  end
end
