import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["step"];

  connect() {
    console.log("Simulation Schedule Controller conectado.");
  }

  updateEndDate(event) {
    const index = event.target.dataset.index;
    const stepElement = this.stepTargets.find(
      (step) => step.dataset.index === index
    );

    if (!stepElement) {
      console.error(`Etapa não encontrada para o índice ${index}`);
      return;
    }

    const startDateInput = stepElement.querySelector(".step-start-date");
    const slaInput = stepElement.querySelector(".step-sla");
    const endDateInput = stepElement.querySelector(".step-end-date");

    const startDate = new Date(startDateInput.value);
    const sla = parseInt(slaInput.value, 10);

    if (isNaN(sla) || isNaN(startDate.getTime())) {
      console.warn("Dados inválidos para cálculo das datas.");
      return;
    }

    // Calcula a nova data de fim
    const endDate = new Date(startDate);
    endDate.setDate(endDate.getDate() + sla);

    // Atualiza o campo de data de fim
    endDateInput.value = endDate.toISOString().split("T")[0];
  }
}
