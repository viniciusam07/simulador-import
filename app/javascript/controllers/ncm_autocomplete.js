import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["input", "description", "suggestions"];

  connect() {
    this.suggestionsTarget.innerHTML = ""; // Limpa as sugestões ao carregar
  }

  async search() {
    const query = this.inputTarget.value.trim();

    if (query.length >= 2) {
      try {
        const response = await fetch(`/ncm_codes/autocomplete?query=${encodeURIComponent(query)}`, {
          headers: {
            Accept: "application/json",
          },
        });

        if (!response.ok) {
          throw new Error(`Erro HTTP! status: ${response.status}`);
        }

        const suggestions = await response.json();

        this.updateSuggestions(suggestions);
      } catch (error) {
        console.error("Erro ao buscar NCMs:", error);
        this.suggestionsTarget.innerHTML = `<option disabled>Erro ao carregar sugestões</option>`;
      }
    } else {
      this.suggestionsTarget.innerHTML = ""; // Limpa as sugestões se o texto for menor que 2 caracteres
    }
  }

  updateSuggestions(suggestions) {
    // Limpa o datalist
    this.suggestionsTarget.innerHTML = "";

    if (suggestions.length > 0) {
      suggestions.slice(0, 5).forEach((item) => {
        const option = document.createElement("option");
        option.value = item.code;
        option.textContent = `${item.code} - ${item.description}`;
        this.suggestionsTarget.appendChild(option);
      });
    } else {
      const option = document.createElement("option");
      option.disabled = true;
      option.textContent = "Nenhuma sugestão encontrada";
      this.suggestionsTarget.appendChild(option);
    }
  }


  select() {
    const selectedCode = this.inputTarget.value;
    const selectedOption = [...this.suggestionsTarget.options].find(
      (option) => option.value === selectedCode
    );

    if (selectedOption) {
      this.descriptionTarget.value = selectedOption.textContent.split(" - ")[1];
    } else {
      this.descriptionTarget.value = "";
    }
  }
}
