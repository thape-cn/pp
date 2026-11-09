/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb

// Uncomment to copy all static images under ./images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('./images', true)
// const imagePath = (name) => images(name, true)
import LocalTime from "local-time"

const localTimeI18n = document.querySelector('meta[name="local-time-i18n"]')
if (localTimeI18n) {
  const locale = document.documentElement.lang
  const translations = LocalTime.config.i18n[locale] ||= {}
  for (const [section, values] of Object.entries(JSON.parse(localTimeI18n.content))) {
    translations[section] = { ...translations[section], ...values }
  }
  LocalTime.config.locale = locale
}

LocalTime.start();
import "simplebar";
