class NcmCodesController < ApplicationController

  def index
    if params[:term].present?
      ncm_codes = NcmCode.where("code LIKE ?", "%#{params[:term]}%").limit(5)
      render json: ncm_codes.to_json(only: [:code, :description])
    else
      render json: []
    end
  end

  def autocomplete
    term = params[:query]
    results = NcmCode.where("code ILIKE ?", "#{term}%")
                     .limit(10)
                     .select(:id, :code, :description)
    render json: results.map { |ncm| { code: ncm.code, description: ncm.description } }
  end
end
