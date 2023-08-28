import { Controller } from "@hotwired/stimulus"
import { get } from '@rails/request.js'

Stimulus.register("toggle-people-performance", class extends Controller {
  static targets = [ "peopleList", "icon" ];
  static values = {
    expanded: { type: Boolean, default: false },
    url: String,
    expandIcon: String,
    shrinkIcon: String
  }

  toggle() {
    console.log(this.iconTarget);
    console.log(this.expandIconValue);
    console.log(this.shrinkIconValue);
    get(`${this.urlValue}&expanded=${this.expandedValue}`).then((response) => {
      if (response.ok) {
        const result_text = response.text;
        result_text.then(result => {
          this.peopleListTarget.innerHTML = result;
          this.expandedValue = !this.expandedValue;
        });
      }
    });
    if (this.expandedValue == true) {
      this.iconTarget.setAttribute('xlink:href', this.expandIconValue);
    } else {
      this.iconTarget.setAttribute('xlink:href', this.shrinkIconValue);
    }
  }
});
