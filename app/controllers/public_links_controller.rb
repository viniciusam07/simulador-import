class PublicLinksController < ApplicationController
  before_action :authenticate_user!

  def create
    @simulation = Simulation.find(public_link_params[:simulation_id])

    if @simulation.public_link.present?
      redirect_to simulation_path(@simulation), alert: "A simulação já possui um link público."
      return
    end

    @public_link = PublicLink.new(public_link_params)

    if @public_link.save
      redirect_to simulation_path(@simulation), notice: "Link público criado com sucesso."
    else
      redirect_to simulation_path(@simulation), alert: @public_link.errors.full_messages.to_sentence
    end
  end

  def edit
    @public_link = PublicLink.find(params[:id])
  end

  def update
    @public_link = PublicLink.find(params[:id])

    if @public_link.update(public_link_params)
      redirect_to simulation_path(@public_link.simulation), notice: "Data de expiração atualizada com sucesso."
    else
      redirect_to simulation_path(@public_link.simulation), alert: @public_link.errors.full_messages.to_sentence
    end
  end

  private

  def public_link_params
    params.require(:public_link).permit(:simulation_id, :expires_at)
  end
end
