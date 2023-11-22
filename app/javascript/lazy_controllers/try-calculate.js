import { Controller } from "@hotwired/stimulus"
import { get } from '@rails/request.js'

Stimulus.register("try-calculate", class extends Controller {
  static values = { groupLevel: String }

  click() {
    console.log(this.groupLevelValue);
  }
});
