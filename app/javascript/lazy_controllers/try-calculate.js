import { Controller } from "@hotwired/stimulus"
import { get } from '@rails/request.js'

Stimulus.register("try-calculate", class extends Controller {
  static targets = [ "icon" ];
  static values = {
    groupLevel: String
  }

  click() {
    console.log("Button clicked");
  }
});
