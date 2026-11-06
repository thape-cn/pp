require "test_helper"

class Edoc2UploadTest < ActiveSupport::TestCase
  setup do
    @euc = evaluation_user_capabilities(:euc_one)
    @euc.edoc_guid = "evaluation-guid"
    @euc.edoc_file_id = "123"
  end

  %w[0 1].each do |state|
    test "metadata follows dossier entry state #{state}" do
      dossier = {"dossierId" => "dossier-guid", "archTypeId" => "archive-type-guid", "entrystate" => state, "agencyFileNumber" => "archive-number"}
      metadata = with_edoc2_dossier(dossier) do
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

  test "metadata uses entry state zero for an archived dossier without an archive number" do
    dossier = {"dossierId" => "dossier-guid", "archTypeId" => "archive-type-guid", "entrystate" => "1", "agencyFileNumber" => ""}

    metadata = with_edoc2_dossier(dossier) do
      assert_equal({"result" => true, "code" => 0}, @euc.upload_meta_arch("2026-07-01"))
    end

    assert_equal "0", metadata[:entrystate]
    assert_equal "dossier-guid", metadata[:dossierId]
    assert_equal "archive-type-guid", metadata[:archtypeid]
    assert_equal [{fileId: 123, operateType: "upload"}], metadata[:fileList]
  end

  test "missing dossier state fails before submitting metadata" do
    with_edoc2_dossier({"dossierId" => "dossier-guid", "archTypeId" => "archive-type-guid"}) do
      assert_raises(KeyError) { @euc.upload_meta_arch("2026-07-01") }
    end
  end

  test "rejected metadata reports the missing archive number for an archived dossier" do
    dossier = {"dossierId" => "dossier-guid", "archTypeId" => "archive-type-guid", "entrystate" => "1", "agencyFileNumber" => ""}
    api_error = Edoc2::Edoc2API_Error.new("参数异常 (1992998)")

    metadata = with_edoc2_dossier(dossier, upload_error: api_error) do
      error = assert_raises(Edoc2::Edoc2API_Error) { @euc.upload_meta_arch("2026-07-01") }
      assert_includes error.message, "EUC #{@euc.id}: archived Edoc2 dossier dossier-guid has no archive number"
      assert_includes error.message, "1992998"
    end

    assert_equal "0", metadata[:entrystate]
  end

  private

  def with_edoc2_dossier(dossier, upload_error: nil)
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
      raise upload_error if upload_error

      {"result" => true, "code" => 0}
    end
    yield
    metadata
  ensure
    Edoc2.define_singleton_method(:get_dossier_and_arch_type_id_list, original_lookup)
    Edoc2.define_singleton_method(:meta_arch, original_upload)
  end
end
