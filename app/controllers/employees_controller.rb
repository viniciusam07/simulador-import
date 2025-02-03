class EmployeesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_enterprise
  before_action :authorize_admin!
  before_action :set_employee, only: %i[edit update destroy]


  def index
    @employees = @enterprise.employees.includes(:user)
  end

  def edit
    @employee.build_user unless @employee.user
  end
  def update
    if @employee.update(employee_params.except(:user))
      if employee_params[:user].present?
        @employee.user.update(employee_params[:user].permit(:first_name, :last_name, :email))
      end
      redirect_to enterprise_path(@enterprise), notice: "Funcionário atualizado com sucesso."
    else
      render :edit, status: :unprocessable_entity
    end
  end
  def new
    @employee = @enterprise.employees.build
    @employee.build_user # Prepara um novo usuário associado
  end

  def create
    email = params[:employee][:user][:email]
    role = params[:employee][:role]

    user = User.find_by(email: email)

    # 🚨 Validação: Se o usuário já pertence à empresa, impedir duplicação
    if user && @enterprise.employees.exists?(user: user)
      redirect_to @enterprise, alert: "Este usuário já é um funcionário da empresa."
      return
    end

    # Criar o usuário automaticamente se não existir
    unless user
      user = User.new(params[:employee][:user].permit(:first_name, :last_name, :email))
      user.password = SecureRandom.hex(10) # Gera uma senha temporária aleatória

      unless user.save
        redirect_to @enterprise, alert: "Erro ao criar o usuário: #{user.errors.full_messages.join(', ')}"
        return
      end
    end

    # Criar o Employee vinculado ao usuário e à empresa
    @employee = @enterprise.employees.build(user: user, role: role)

    if @employee.save
      redirect_to @enterprise, notice: "Funcionário adicionado com sucesso."
    else
      redirect_to @enterprise, alert: "Erro ao adicionar funcionário: #{@employee.errors.full_messages.join(', ')}"
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
  def set_employee
      @employee = @enterprise.employees.find(params[:id])
  rescue ActiveRecord::RecordNotFound
      redirect_to enterprise_path(@enterprise), alert: "Funcionário não encontrado."
  end

  def authorize_admin!
    unless current_user.super_admin? || current_user.employee&.owner? || current_user.employee&.admin?
      redirect_to enterprises_path, alert: "Você não tem permissão para essa ação."
    end
  end
  def employee_params
    params.require(:employee).permit(:role, user: [:first_name, :last_name, :email])
  end
end
