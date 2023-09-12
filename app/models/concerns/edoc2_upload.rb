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
      res = Edoc2.collect_archives_enclosure_file(pdf_path, "#{user.chinese_name}#{user.clerk_code}_#{company_evaluation_template.title}_#{id}.pdf", edoc_guid)
      update(edoc_file_id: res[0]["fileId"])
    end

    def upload_meta_arch
      return unless edoc_file_id.present? && edoc_guid.present?

      res = Edoc2.get_dossier_and_arch_type_id_list(user.clerk_code)

      if res.length > 0
        dossier_id = res[0]["dossierId"]
        arch_type_id = res[0]["archTypeId"]

        file_info_hash = {
          Id: edoc_guid,
          entrystate: "1", # 档案库
          archtypeid: arch_type_id,
          name: "#{user.chinese_name}#{user.clerk_code} #{company_evaluation_template.title}_#{id}",
          pnName: user.chinese_name,
          number: "",
          carrier: "电子",
          objtype: "",
          entitynum: "",
          writtendate: "2023-07-01",
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
        meta_arch_return_hash = Edoc2.meta_arch(file_info_hash)
        Rails.logger.info "meta_arch_return_hash: #{meta_arch_return_hash}"
        meta_arch_return_hash
      end
    end
  end
end
