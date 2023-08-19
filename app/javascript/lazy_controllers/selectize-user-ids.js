import { Controller } from "@hotwired/stimulus"

let userID_Select;

Stimulus.register("selectize-user-ids", class extends Controller {
  static targets = [ "selectBox" ]

  connect() {
    userID_Select = $(this.selectBoxTarget).selectize({
      plugins: ["remove_button"],
      respect_word_boundaries: false,
      valueField: "id",
      labelField: "name",
      searchField: "name",
      create: false,
      load: function (query, callback) {
        if (!query.length) return callback();
        $.ajax({
          url: "/ui/user_select.json?q=" + encodeURIComponent(query),
          type: "GET",
          error: function () {
            callback();
          },
          success: function (res) {
            callback(res.users);
          },
        });
      },
    });
  }

  disconnect() {
    const need_destroy = userID_Select[0].selectize;
    if(need_destroy) {
      need_destroy.destroy();
    }
  }
});
