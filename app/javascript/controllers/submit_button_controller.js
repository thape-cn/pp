import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    formId: String
  }

  click(event) {
    event.preventDefault();
    document.getElementById(this.formIdValue).submit();
  }
}
