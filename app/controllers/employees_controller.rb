class EmployeesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_enterprise
  before_action :authorize_admin!

  def index
    @employees = @enterprise.employees.includes(:user)
  end

  def create
    user = User.find_by(email: params[:email])

    if user.nil?
      redirect_to @enterprise, alert: "Usuário não encontrado."
      return
    end

    if @enterprise.employees.exists?(user: user)
      redirect_to @enterprise, alert: "Este usuário já é um funcionário da empresa."
      return
    end

    @employee = @enterprise.employees.build(user: user, role: params[:role])

    if @employee.save
      redirect_to @enterprise, notice: "Funcionário adicionado com sucesso."
    else
      redirect_to @enterprise, alert: "Erro ao adicionar funcionário."
    end
  end

  def update
    @employee = @enterprise.employees.find(params[:id])

    if @employee.update(role: params[:role])
      redirect_to @enterprise, notice: "Papel atualizado com sucesso."
    else
      redirect_to @enterprise, alert: "Erro ao atualizar papel."
    end
  end

  def destroy
    @employee = @enterprise.employees.find(params[:id])
    @employee.destroy
    redirect_to @enterprise, notice: "Funcionário removido com sucesso."
  end

  private

  def set_enterprise
    @enterprise = Enterprise.find(params[:enterprise_id])
  end

  def authorize_admin!
    unless current_user.super_admin? || current_user.employee&.owner? || current_user.employee&.admin?
      redirect_to enterprises_path, alert: "Você não tem permissão para essa ação."
    end
  end
end
