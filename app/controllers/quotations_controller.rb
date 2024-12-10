class QuotationsController < ApplicationController
  before_action :set_product
  before_action :set_quotation, only: [:edit, :update, :destroy]

  def new
    @quotation = @product.quotations.build
  end

  def create
    @product = Product.find(params[:product_id])
    @quotation = @product.quotations.build(quotation_params)

    if @quotation.save
      redirect_to @product, notice: 'Cotação criada com sucesso.'
    else
      flash.now[:alert] = 'Erro ao salvar cotação. Verifique os campos.'
      render 'products/show'
    end
  end

  def edit; end

  def update
    if @quotation.update(quotation_params)
      redirect_to @product, notice: "Cotação atualizada com sucesso."
    else
      render :edit
    end
  end

  def destroy
    @quotation.destroy
    redirect_to @product, notice: "Cotação removida com sucesso."
  end

  private

  def set_product
    @product = Product.find(params[:product_id])
  end

  def set_quotation
    @quotation = @product.quotations.find(params[:id])
  end

  def quotation_params
    params.require(:quotation).permit(:supplier_id, :price, :currency, :validity, :moq, :payment_terms, :lead_time)
  end
end
