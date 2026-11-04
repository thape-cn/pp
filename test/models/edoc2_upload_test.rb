require "test_helper"

class Edoc2UploadTest < ActiveSupport::TestCase
  setup do
    @euc = evaluation_user_capabilities(:euc_one)
    @euc.edoc_guid = "evaluation-guid"
    @euc.edoc_file_id = "123"
  end

  %w[0 1].each do |state|
    test "metadata follows dossier entry state #{state}" do
      metadata = with_edoc2_dossier("dossierId" => "dossier-guid", "archTypeId" => "archive-type-guid", "entrystate" => state) do
        @euc.upload_meta_arch("2026-07-01")
      end

      assert_equal state, metadata[:entrystate]
      assert_equal "dossier-guid", metadata[:dossierId]
      assert_equal "archive-type-guid", metadata[:archtypeid]
      assert_equal "evaluation-guid", metadata[:Id]
      assert_equal "2026-07-01", metadata[:writtendate]
      assert_equal [{fileId: 123, operateType: "upload"}], metadata[:fileList]
    end
  end

  test "missing dossier state fails before submitting metadata" do
    with_edoc2_dossier("dossierId" => "dossier-guid", "archTypeId" => "archive-type-guid") do
      assert_raises(KeyError) { @euc.upload_meta_arch("2026-07-01") }
    end
  end

  private

  def with_edoc2_dossier(dossier)
    original_lookup = Edoc2.method(:get_dossier_and_arch_type_id_list)
    original_upload = Edoc2.method(:meta_arch)
    metadata = nil
    expected_clerk_code = @euc.user.clerk_code
    Edoc2.define_singleton_method(:get_dossier_and_arch_type_id_list) do |clerk_code|
      raise "Unexpected clerk code" unless clerk_code == expected_clerk_code

      [dossier]
    end
    Edoc2.define_singleton_method(:meta_arch) do |payload|
      metadata = payload
      {"result" => true, "code" => 0}
    end
    yield
    metadata
  ensure
    Edoc2.define_singleton_method(:get_dossier_and_arch_type_id_list, original_lookup)
    Edoc2.define_singleton_method(:meta_arch, original_upload)
  end
end
