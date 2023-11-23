import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    formId: String
  }

  click(e) {
    e.preventDefault();
    document.getElementById(this.formIdValue).submit();
  }
}
