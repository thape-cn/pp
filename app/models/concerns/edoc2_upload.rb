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
      browser.reset
    end

    def upload_pdf_to_edoc
      return if edoc_guid.blank?
      return if edoc_file_id.present?

      pdf_path = Rails.root.join("edoc_guid_pdf/#{edoc_guid}.pdf")
      res = Edoc2.collect_archives_enclosure_file(pdf_path, "#{user.clerk_code}#{user.chinese_name}#{company_evaluation_template.title}_#{id}.pdf", edoc_guid)
      update(edoc_file_id: res[0]["fileId"])
    end

    def upload_meta_arch(written_date)
      return unless edoc_file_id.present? && edoc_guid.present?

      dossier = Edoc2.get_dossier_and_arch_type_id_list(user.clerk_code).first

      if dossier
        dossier_id = dossier["dossierId"]
        entry_state = dossier.fetch("entrystate")

        file_info_hash = {
          Id: edoc_guid,
          entrystate: entry_state, # 跟随所属案卷的归档状态
          archtypeid: dossier["archTypeId"],
          name: "#{user.clerk_code}#{user.chinese_name}#{company_evaluation_template.title}_#{id}",
          pnName: user.chinese_name,
          number: "",
          carrier: "电子",
          objtype: "",
          entitynum: "",
          writtendate: written_date,
          duration: "永久",
          secert: "普通商密",
          ifInbound: "0",
          storageroomId: "",
          ifDossiered: "1", # 是卷内文件
          dossierId: dossier_id,
          dataSources: "HR系统",
          agencyItemNumber: "1",
          totalNumberPages: "",
          achievePeople: "PP系统",
          materialType1: "人才发展类",
          materialType2: "员工绩效考核表",
          contractType: "",
          contractValidity: "",
          interviewDate: "",
          assessmentClassification: "",
          evaluationDate: "",
          pnCode: user.clerk_code,
          fileList: [{
            fileId: edoc_file_id.to_i,
            operateType: "upload"
          }]
        }
        Rails.logger.info "file_info_hash: #{file_info_hash}"
        begin
          meta_arch_return_hash = Edoc2.meta_arch(file_info_hash)
        rescue Edoc2::Edoc2API_Error => error
          if entry_state.to_s == "1" && dossier["agencyFileNumber"].blank?
            raise Edoc2::Edoc2API_Error,
              "EUC #{id}: archived Edoc2 dossier #{dossier_id} has no archive number (agencyFileNumber). #{error.message}"
          end
          raise
        end
        Rails.logger.info "meta_arch_return_hash: #{meta_arch_return_hash}"
        meta_arch_return_hash
      end
    end
  end
end
