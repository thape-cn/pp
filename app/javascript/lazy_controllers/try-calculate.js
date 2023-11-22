import { Controller } from "@hotwired/stimulus"
import { get } from '@rails/request.js'

Stimulus.register("try-calculate", class extends Controller {
  static targets = [ "peopleCount", "apa", "b", "cd", "below", "standard", "beyond",
   "apaRate", "bRate", "cdRate", "belowRate", "standardRate", "beyondRate"]
  static values = { groupLevel: String }

  click() {
    event.preventDefault();
    const url = ['staff', 'auxiliary'].includes(this.groupLevelValue) ?
      `/admin/calibration_sessions/calculate.json?group_level=${this.groupLevelValue}&people=${this.peopleCountTarget.value}&apa=${this.apaRateTarget.value}&b=${this.bRateTarget.value}&cd=${this.cdRateTarget.value}` :
      `/admin/calibration_sessions/calculate.json?group_level=${this.groupLevelValue}&people=${this.peopleCountTarget.value}&beyond=${this.beyondRateTarget.value}&standard=${this.standardRateTarget.value}&below=${this.belowRateTarget.value}`;

    get(url).then((response) => {
      if (response.ok) {
        const result_json = response.json;
        result_json.then(result => {
          console.log(result);
        });
      }
    });
  }
});
