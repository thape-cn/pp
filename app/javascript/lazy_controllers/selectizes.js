import { Controller } from "@hotwired/stimulus"

Stimulus.register("selectizes", class extends Controller {
  static targets = [ "select" ]

  connect() {
    $(this.selectTarget).selectize({
      plugins: ["remove_button"],
      respect_word_boundaries: false
    });
  }

  disconnect() {
    const need_destroy = $(this.selectTarget)[0].selectize;
    if(need_destroy) {
      need_destroy.destroy();
    }
  }
});
