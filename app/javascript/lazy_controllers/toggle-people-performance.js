import { Controller } from "@hotwired/stimulus"
import { get } from '@rails/request.js'

Stimulus.register("toggle-people-performance", class extends Controller {
  static targets = [ "peopleList" ];
  static values = {
    url: String
  }

  toggle() {
    get(this.urlValue).then((response) => {
      if (response.ok) {
        const result_text = response.text;
        result_text.then(result => {
          this.peopleListTarget.innerHTML = result;
        });
      }
    });
  }
});
