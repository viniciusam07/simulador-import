import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "modal",
    "maritimeFields",
    "airFields",
    "equipmentFields",
    "cargoTypeField"
  ];

  connect() {
    this.toggleFields(); // Atualiza os campos no carregamento inicial
  }

  toggleFields() {
    const modalValue = this.modalTarget.value;

    // Exibe os campos de acordo com o modal selecionado
    this.maritimeFieldsTarget.style.display = modalValue === "Marítimo" ? "block" : "none";
    this.airFieldsTarget.style.display = modalValue === "Aéreo" ? "block" : "none";

    // Exibe os campos adicionais de Equipamento e Quantidade apenas para Marítimo
    if (this.hasEquipmentFieldsTarget) {
      this.equipmentFieldsTarget.style.display = modalValue === "Marítimo" ? "block" : "none";
    }

    // Exibe o campo Tipo de Carga (FLC ou LCL) apenas para Marítimo
    if (this.hasCargoTypeFieldTarget) {
      this.cargoTypeFieldTarget.style.display = modalValue === "Marítimo" ? "block" : "none";
    }
  }
}
