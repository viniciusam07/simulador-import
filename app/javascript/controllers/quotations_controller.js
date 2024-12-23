import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["list", "item"];

  add(event) {
    event.preventDefault();
    const template = this.itemTarget.cloneNode(true);
    template.querySelectorAll("input, select").forEach((field) => {
      field.value = "";
    });
    this.listTarget.appendChild(template);
  }

  remove(event) {
    event.preventDefault();
    const item = event.target.closest("[data-quotations-target='item']");
    if (item) {
      item.remove();
    }
  }

  loadUnitPrice(event) {
    const quotationId = event.target.value;
    const item = event.target.closest("[data-quotations-target='item']");
    if (!item) {
      console.error("Elemento item não encontrado.");
      return;
    }

    const unitPriceInput = item.querySelector("input[name*='custom_price']");
    if (!unitPriceInput) {
      console.error("Campo custom_price não encontrado.");
      return;
    }

    if (quotationId) {
      fetch(`/quotations/${quotationId}.json`)
        .then((response) => {
          if (!response.ok) {
            throw new Error(`HTTP error! Status: ${response.status}`);
          }
          return response.json();
        })
        .then((data) => {
          if (data.price !== undefined) {
            unitPriceInput.value = data.price;
            this.updateTotal(item);
          } else {
            console.error("Preço não encontrado na resposta:", data);
          }
        })
        .catch((error) => console.error("Erro ao carregar o preço unitário:", error));
    }
  }

  updateTotal(item) {
    const quantityInput = item.querySelector("input[name*='quantity']");
    const unitPriceInput = item.querySelector("input[name*='custom_price']");
    const totalValueInput = item.querySelector("input[name*='total_value']");

    if (!quantityInput || !unitPriceInput || !totalValueInput) {
      console.error("Campos necessários para cálculo não encontrados.");
      return;
    }

    const quantity = parseFloat(quantityInput.value) || 0;
    const unitPrice = parseFloat(unitPriceInput.value) || 0;

    totalValueInput.value = (quantity * unitPrice).toFixed(2);
  }
}
