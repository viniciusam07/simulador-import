import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["availableList", "selectedList"];

  add(event) {
    event.preventDefault();

    const button = event.target;
    const stepId = button.dataset.stepIdValue;
    const stepName = button.dataset.stepNameValue;
    const stepSla = button.dataset.stepSlaValue;

    console.log(`Adicionando Step: ID=${stepId}, Nome=${stepName}, SLA=${stepSla}`);

    if (!stepId || !stepName || !stepSla) {
      console.error("Erro: ID, Nome ou SLA do Step não encontrado.");
      return;
    }

    if (this.selectedListTarget.querySelector(`[data-step-id="${stepId}"]`)) {
      console.warn(`Step ${stepId} já está na lista de selecionados.`);
      return;
    }

    const order = this.selectedListTarget.children.length + 1;

    const selectedStep = document.createElement("div");
    selectedStep.classList.add("selected-step", "mb-2", "p-2", "border");
    selectedStep.dataset.stepId = stepId;
    selectedStep.dataset.stepName = stepName;
    selectedStep.dataset.stepSla = stepSla;

    selectedStep.innerHTML = `
    <strong>${stepName}</strong> - SLA: ${stepSla} dias
    <input type="hidden" name="schedule[schedule_steps_attributes][][step_id]" value="${stepId}">
    <input type="hidden" name="schedule[schedule_steps_attributes][][order]" value="${order}">
    <input type="hidden" name="schedule[schedule_steps_attributes][][_destroy]" value="false" class="destroy-flag">
    <a href="#" class="btn btn-danger btn-sm remove-step" data-action="click->schedule-steps#remove">Remover</a>
  `;

    this.selectedListTarget.appendChild(selectedStep);

    const stepElement = button.closest(".available-step");
    if (stepElement) stepElement.remove();
  }


  remove(event) {
    event.preventDefault();

    const stepElement = event.target.closest(".selected-step");
    if (!stepElement) {
      console.error("Elemento do step não encontrado.");
      return;
    }

    const stepId = stepElement.dataset.stepId;
    const stepName = stepElement.dataset.stepName;
    const stepSla = stepElement.dataset.stepSla;

    if (!stepId || !stepName || !stepSla) {
      console.error(`Erro ao obter detalhes do step. ID=${stepId}, Nome=${stepName}, SLA=${stepSla}`);
      return;
    }

    // Adiciona o Step de volta à lista de Steps Disponíveis
    const availableStep = document.createElement("div");
    availableStep.classList.add("available-step", "mb-2", "p-2", "border");
    availableStep.dataset.stepId = stepId;
    availableStep.dataset.stepName = stepName;
    availableStep.dataset.stepSla = stepSla;

    availableStep.innerHTML = `
    <strong>${stepName}</strong> - SLA: ${stepSla} dias
    <a href="#" class="btn btn-primary btn-sm add-step"
      data-action="click->schedule-steps#add"
      data-step-id-value="${stepId}"
      data-step-name-value="${stepName}"
      data-step-sla-value="${stepSla}">
      Adicionar
    </a>
  `;

    this.availableListTarget.appendChild(availableStep);

    // Remove o Step da lista de selecionados
    stepElement.remove();
  }
}
