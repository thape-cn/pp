class AddDeletedReasonAndUserToArchivedEvaluationUserCapability < ActiveRecord::Migration[7.1]
  def change
    add_column :archived_evaluation_user_capabilities, :deleted_reason, :string
    add_reference :archived_evaluation_user_capabilities, :deleted_user, null: false
    default_user = User.find_by(email: "guochunzhong@thape.com.cn")
    ArchivedEvaluationUserCapability.where(deleted_user_id: 0).update_all(deleted_user_id: default_user&.id)
  end
end
