import { Controller } from "@hotwired/stimulus"
import { get } from '@rails/request.js'

Stimulus.register("try-calculate", class extends Controller {
  static targets = [ "apa", "b", "cd", "below", "standard", "beyond" ]
  static values = { groupLevel: String }

  click() {
    if (['staff', 'auxiliary'].includes(this.groupLevelValue)) {
      console.log(this.apaTarget);
      console.log(this.bTarget);
      console.log(this.cdTarget);
    } else {
      console.log(this.beyondTarget);
      console.log(this.standardTarget);
      console.log(this.belowTarget);
    }
  }
});
