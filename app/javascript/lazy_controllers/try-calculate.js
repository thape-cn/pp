import { Controller } from "@hotwired/stimulus"
import { get } from '@rails/request.js'

Stimulus.register("try-calculate", class extends Controller {
  static targets = [ "apa", "b", "cd", "below", "standard", "beyond",
   "apaRate", "bRate", "cdRate", "belowRate", "standardRate", "beyondRate"]
  static values = { groupLevel: String }

  click() {
    if (['staff', 'auxiliary'].includes(this.groupLevelValue)) {
      console.log(this.apaRateTarget);
      console.log(this.bRateTarget);
      console.log(this.cdRateTarget);
    } else {
      console.log(this.beyondRateTarget);
      console.log(this.standardRateTarget);
      console.log(this.belowRateTarget);
    }
  }
});
