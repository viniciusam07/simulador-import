import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["list", "item", "template"];

  connect() {
    this.toggleRemoveButtons();
  }

  // Adiciona um novo item à lista de cotações
  add(event) {
    event.preventDefault();

    // Clona o template oculto
    const template = this.templateTarget.content.cloneNode(true);

    // Adiciona o novo item à lista
    this.listTarget.appendChild(template);

    // Atualiza os botões de remoção
    this.toggleRemoveButtons();
  }

  // Remove um item da lista de cotações
  remove(event) {
    event.preventDefault();
    const item = event.target.closest("[data-quotations-target='item']");

    if (item) {
      item.remove();
      this.toggleRemoveButtons();
    }
  }

  // Verifica e desabilita o botão "Remover" se houver apenas uma cotação
  toggleRemoveButtons() {
    const removeButtons = this.listTarget.querySelectorAll("[data-action='click->quotations#remove']");

    if (removeButtons.length === 1) {
      removeButtons[0].disabled = true;
    } else {
      removeButtons.forEach(button => button.disabled = false);
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
            unitPriceInput.value = data.price;
            this.updateTotal({ target: unitPriceInput });
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

    totalValueInput.value = (quantity * unitPrice).toFixed(2);
  }
}
