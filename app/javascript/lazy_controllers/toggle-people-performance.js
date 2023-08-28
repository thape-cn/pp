import { Controller } from "@hotwired/stimulus"
import { get } from '@rails/request.js'

Stimulus.register("toggle-people-performance", class extends Controller {
  static targets = [ "peopleList" ];
  static values = {
    expanded: { type: Boolean, default: false },
    url: String
  }

  toggle() {
    console.log(this.expandedValue);
    get(`${this.urlValue}&expanded=${this.expandedValue}`).then((response) => {
      if (response.ok) {
        const result_text = response.text;
        result_text.then(result => {
          this.peopleListTarget.innerHTML = result;
          this.expandedValue = !this.expandedValue;
        });
      }
    });
  }
});
