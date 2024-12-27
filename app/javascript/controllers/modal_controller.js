import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["modal", "maritimeFields", "airFields"];

  connect() {
    this.toggleFields(); // Atualiza os campos no carregamento inicial
  }

  toggleFields() {
    const modalValue = this.modalTarget.value;

    // Exibe os campos de acordo com o modal selecionado
    this.maritimeFieldsTarget.style.display = modalValue === "Marítimo" ? "block" : "none";
    this.airFieldsTarget.style.display = modalValue === "Aéreo" ? "block" : "none";
  }
}
