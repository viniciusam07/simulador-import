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
}
