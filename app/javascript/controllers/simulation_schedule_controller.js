import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["step", "stepsList"];

  connect() {
    console.log("Simulation Schedule Controller conectado.");
  }

  async loadSchedule(event) {
    const scheduleId = event.target.value;

    if (!scheduleId) return;

    try {
      const response = await fetch(`/schedules/${scheduleId}/details`, {
        headers: { "Content-Type": "application/json" },
      });

      if (!response.ok) {
        throw new Error("Erro ao carregar o cronograma selecionado.");
      }

      const data = await response.json();
      this.generateTable(data.steps);
    } catch (error) {
      console.error("Erro ao carregar cronograma:", error);
    }
  }

  generateTable(steps) {
    let currentStartDate = new Date();
    this.stepsListTarget.innerHTML = steps
      .map((step, index) => {
        const stepSla = parseInt(step.sla, 10) || 0;
        const endDate = new Date(currentStartDate);
        endDate.setDate(endDate.getDate() + stepSla);

        const formattedStartDate = currentStartDate.toISOString().split("T")[0];
        const formattedEndDate = endDate.toISOString().split("T")[0];

        const row = `
          <tr data-simulation-schedule-target="step" data-index="${index}">
            <td>
              <input type="hidden" name="simulation_schedule[steps][${index}][name]" value="${step.name}">
              <strong>${step.name}</strong>
            </td>
            <td>
              <input type="date" name="simulation_schedule[steps][${index}][start_date]" value="${formattedStartDate}" class="form-control step-start-date" data-action="input->simulation-schedule#updateEndDate" data-index="${index}">
            </td>
            <td>
              <input type="number" name="simulation_schedule[steps][${index}][sla]" value="${stepSla}" class="form-control step-sla" min="1" data-action="input->simulation-schedule#updateEndDate" data-index="${index}">
            </td>
            <td>
              <input type="date" name="simulation_schedule[steps][${index}][end_date]" value="${formattedEndDate}" class="form-control step-end-date" readonly>
            </td>
          </tr>`;
        currentStartDate = endDate;
        return row;
      })
      .join("");
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

    const endDate = new Date(startDate);
    endDate.setDate(endDate.getDate() + sla);

    endDateInput.value = endDate.toISOString().split("T")[0];
  }
}
