import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["list", "item"];

  // Adiciona um novo item à lista de cotações
  add(event) {
    event.preventDefault();

    const template = this.itemTarget.cloneNode(true);
    template.querySelectorAll("input, select").forEach((field) => {
      field.value = "";
    });

    // Garante que o novo item tenha o atributo necessário
    template.setAttribute("data-quotations-target", "item");

    this.listTarget.appendChild(template);
  }

  // Remove um item da lista de cotações
  remove(event) {
    event.preventDefault();
    const item = event.target.closest("[data-quotations-target='item']");
    if (item) {
      item.remove();
    }
  }

  // Carrega o preço unitário da cotação selecionada
  loadUnitPrice(event) {
    const quotationId = event.target.value;
    const item = event.target.closest("[data-quotations-target='item']");

    if (!item) {
      console.error("Elemento 'item' não encontrado.");
      return;
    }

    const unitPriceInput = item.querySelector("input[name*='custom_price']");
    if (!unitPriceInput) {
      console.error("Campo 'custom_price' não encontrado.");
      return;
    }

    if (quotationId) {
      fetch(`/quotations/${quotationId}.json`)
        .then((response) => {
          if (!response.ok) {
            throw new Error(`Erro HTTP! Status: ${response.status}`);
          }
          return response.json();
        })
        .then((data) => {
          if (data.price !== undefined) {
            unitPriceInput.value = data.price; // Preenche o campo com o preço retornado
            this.updateTotal({ target: unitPriceInput }); // Atualiza o valor total
          } else {
            console.error("Preço não encontrado na resposta:", data);
          }
        })
        .catch((error) => console.error("Erro ao carregar o preço unitário:", error));
    }
  }

  // Atualiza o valor total da cotação com base na quantidade e no preço unitário
  updateTotal(event) {
    const item = event.target.closest("[data-quotations-target='item']");

    if (!item) {
      console.error("Elemento 'item' não encontrado.");
      return;
    }

    const quantityInput = item.querySelector("input[name*='quantity']");
    const unitPriceInput = item.querySelector("input[name*='custom_price']");
    const totalValueInput = item.querySelector("input[name*='total_value']");

    if (!quantityInput || !unitPriceInput || !totalValueInput) {
      console.error("Campos necessários para cálculo não encontrados.");
      return;
    }

    const quantity = parseFloat(quantityInput.value) || 0;
    const unitPrice = parseFloat(unitPriceInput.value) || 0;

    // Atualiza o campo de valor total
    totalValueInput.value = (quantity * unitPrice).toFixed(2);
  }
}
