module Edoc2Upload
  extend ActiveSupport::Concern

  included do
    def generate_pdf_file
      return if edoc_guid.present?

      browser = Ferrum::Browser.new
      browser.go_to Rails.application.routes.url_helpers.staff_printing_url(id: id)
      browser.network.wait_for_idle
      guid = SecureRandom.uuid
      pdf_path = Rails.root.join("edoc_guid_pdf/#{guid}.pdf")
      browser.pdf(path: pdf_path)
      update(edoc_guid: guid)
    end

    def upload_pdf_to_edoc
      return if edoc_guid.blank?
      return if edoc_file_id.present?

      pdf_path = Rails.root.join("edoc_guid_pdf/#{edoc_guid}.pdf")
      res = Edoc2.collect_archives_enclosure_file(pdf_path, edoc_guid)
      update(edoc_file_id: res[0]["fileId"])
    end
  end
end
