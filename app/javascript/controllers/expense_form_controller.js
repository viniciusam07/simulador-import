import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["fixedFields", "percentageFields"];

  connect() {
    this.toggleFields(); // Inicializa os campos corretamente ao carregar a página
  }

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
}
