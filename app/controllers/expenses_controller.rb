class ExpensesController < ApplicationController
  before_action :set_expense, only: [:edit, :update, :destroy, :show]

  # Lista todas as despesas padrão
  def index
    @expenses = Expense.all
  end

  # Formulário para criar nova despesa
  def new
    @expense = Expense.new
  end

  # Cria uma nova despesa
  def create
    @expense = Expense.new(expense_params)
    if @expense.save
      redirect_to expenses_path, notice: "Despesa criada com sucesso."
    else
      render :new, status: :unprocessable_entity, alert: "Erro ao criar uma despesa"
    end
  end

  # Formulário para editar uma despesa
  def edit
  end

  # Atualiza uma despesa existente
  def update
    if @expense.update(expense_params)
      redirect_to expenses_path, notice: "Despesa atualizada com sucesso."
    else
      render :edit
    end
  end

  # Exclui uma despesa
  def destroy
    @expense.destroy
    redirect_to expenses_path, notice: "Despesa excluída com sucesso."
  end

  # Exibe uma despesa específica
  def show
  end

  private

  # Define a despesa a ser editada, atualizada, excluída ou exibida
  def set_expense
    @expense = Expense.find(params[:id])
  end

  # Define os parâmetros permitidos para a criação ou atualização de uma despesa
  def expense_params
    params.require(:expense).permit(
      :expense_name,
      :expense_description,
      :expense_default_value,
      :expense_currency,
      :expense_location,
      :percentage,
      :calculation_base,
      :type_of_expense
    )
  end
end
