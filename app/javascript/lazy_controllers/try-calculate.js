import { Controller } from "@hotwired/stimulus"
import { get } from '@rails/request.js'

Stimulus.register("try-calculate", class extends Controller {
  static targets = [ "peopleCount", "apa", "b", "cd", "below", "standard", "beyond",
   "apaRate", "bRate", "cdRate", "belowRate", "standardRate", "beyondRate"]
  static values = { groupLevel: String }

  click(e) {
    e.preventDefault();
    const url = ['staff', 'auxiliary'].includes(this.groupLevelValue) ?
      `/admin/calibration_sessions/calculate.json?group_level=${this.groupLevelValue}&people=${this.peopleCountTarget.value}&apa=${this.apaRateTarget.value}&b=${this.bRateTarget.value}&cd=${this.cdRateTarget.value}` :
      `/admin/calibration_sessions/calculate.json?group_level=${this.groupLevelValue}&people=${this.peopleCountTarget.value}&beyond=${this.beyondRateTarget.value}&standard=${this.standardRateTarget.value}&below=${this.belowRateTarget.value}`;

    get(url).then((response) => {
      if (response.ok) {
        const result_json = response.json;
        result_json.then(result => {
          if (['staff', 'auxiliary'].includes(result.group_level)) {
            this.apaTarget.innerHTML = result.apa_grade_rate;
            this.bTarget.innerHTML = result.b_grade_rate;
            this.cdTarget.innerHTML = result.cd_grade_rate;
          } else {
            this.beyondTarget.innerHTML = result.beyond_standard_rate;
            this.standardTarget.innerHTML = result.standards_compliant_rate;
            this.belowTarget.innerHTML = result.below_standard_rate;
          }
        });
      }
    });
  }
});
