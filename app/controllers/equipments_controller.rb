class EquipmentsController < ApplicationController
  def index
    @equipments = Equipment.all
    render json: @equipments
  end
end
