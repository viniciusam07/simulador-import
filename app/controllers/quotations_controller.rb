class QuotationsController < ApplicationController
  before_action :set_product, except: [:index, :show]
  before_action :set_quotation, only: [:edit, :update, :destroy]
def index
  @pagy, @quotations = pagy(
    Quotation.includes(:product, :supplier).order(updated_at: :desc)
  )
end
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
      render 'products/show', status: :unprocessable_entity
    end
  end

  def show
    quotation = Quotation.find(params[:id])
    render json: { id: quotation.id, price: quotation.price, currency: quotation.currency }
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

  def unit_price
    quotation = Quotation.find_by(id: params[:id])

    if quotation
      render json: { unit_price: quotation.price }
    else
      render json: { error: "Cotação não encontrada" }, status: :not_found
    end
  end

  private

  def set_product
    @product = Product.find(params[:product_id])
  end

  def set_quotation
    @quotation = @product.quotations.find(params[:id])
  end

  def quotation_params
    params.require(:quotation).permit(
      :supplier_id, :price, :currency, :validity, :moq, :payment_terms, :lead_time,
      :sku_supplier_id, :total_cbm, :cargo_type,
      :total_gross_weight, :total_net_weight, :observations, :product_quotation_description
    )
  end
end
