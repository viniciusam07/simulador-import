import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  format(event) {
    const field = event.target;
    field.value = field.value
      .replace(/\D/g, "") // Remove caracteres não numéricos
      .replace(/^(\d{2})(\d)/, "$1.$2")
      .replace(/^(\d{2})\.(\d{3})(\d)/, "$1.$2.$3")
      .replace(/\.(\d{3})(\d)/, ".$1/$2")
      .replace(/(\d{4})(\d)/, "$1-$2")
      .substring(0, 18); // Limita a 18 caracteres
  }
}
