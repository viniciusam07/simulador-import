class PublicSimulationsController < ApplicationController
  layout "public"
  skip_before_action :authenticate_user!
  before_action :set_public_link

  def show
    @simulation = @public_link.simulation
    @expired = @public_link.expired?

    # Só cria o acesso se o link não estiver expirado
    unless @expired
      @public_link.public_link_accesses.create!(
        ip: request.remote_ip,
        user_agent: request.user_agent,
        accessed_at: Time.current
      )
    end

    @unit_cost_summary = @simulation.unit_cost_summary

    render template: "pages/public_simulation", layout: "public"
  end

  def track_access
    @public_link.public_link_accesses.create!(
      ip: request.remote_ip,
      user_agent: request.user_agent,
      accessed_at: Time.current
    )

    head :ok
  end

  private

  def set_public_link
    @public_link = PublicLink.includes(:simulation).find_by!(token: params[:token])
  rescue ActiveRecord::RecordNotFound
    redirect_to unauthenticated_root_path, alert: "Link inválido ou não encontrado."
  end
end
