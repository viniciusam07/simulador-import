import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["fixedFields", "percentageFields", "filter", "tableRow"];

  connect() {
    this.toggleFields(); // Inicializa os campos corretamente ao carregar a página
    console.log("ExpenseFormController conectado");
  }

  /**
   * Alterna a visibilidade dos campos com base no tipo de despesa selecionado (fixa ou percentual).
   */
  toggleFields() {
    const typeOfExpense = document.querySelector('input[name="expense[type_of_expense]"]:checked');

    if (typeOfExpense?.value === "fixed") {
      this.fixedFieldsTarget.style.display = "block";
      this.percentageFieldsTarget.style.display = "none";
    } else if (typeOfExpense?.value === "percentage") {
      this.fixedFieldsTarget.style.display = "none";
      this.percentageFieldsTarget.style.display = "block";
    } else {
      // Oculta ambos os campos caso nada seja selecionado
      this.fixedFieldsTarget.style.display = "none";
      this.percentageFieldsTarget.style.display = "none";
    }
  }

  /**
   * Filtra as despesas na tabela com base no valor digitado no campo de filtro.
   */
  filterExpenses() {
    const filterValue = this.filterTarget.value.toLowerCase(); // Valor do filtro em minúsculas

    this.tableRowTargets.forEach((row) => {
      const name = row.dataset.name.toLowerCase(); // Nome da despesa (data-name)
      row.style.display = name.includes(filterValue) ? "" : "none";
    });
  }
}
