class AddCapabilitiesAndArchived2026Mid < ActiveRecord::Migration[8.1]
  def change
    # 复杂底盘
    add_column :evaluation_user_capabilities, :complex_chassis_design, :decimal, precision: 5, scale: 2
    add_column :archived_evaluation_user_capabilities, :complex_chassis_design, :decimal, precision: 5, scale: 2
    # 立面
    add_column :evaluation_user_capabilities, :facade_design, :decimal, precision: 5, scale: 2
    add_column :archived_evaluation_user_capabilities, :facade_design, :decimal, precision: 5, scale: 2
    # 深化设计
    add_column :evaluation_user_capabilities, :detail_design, :decimal, precision: 5, scale: 2
    add_column :archived_evaluation_user_capabilities, :detail_design, :decimal, precision: 5, scale: 2
    # 产品
    add_column :evaluation_user_capabilities, :product_design, :decimal, precision: 5, scale: 2
    add_column :archived_evaluation_user_capabilities, :product_design, :decimal, precision: 5, scale: 2
    # 总图
    add_column :evaluation_user_capabilities, :master_planning, :decimal, precision: 5, scale: 2
    add_column :archived_evaluation_user_capabilities, :master_planning, :decimal, precision: 5, scale: 2
    # 项目管理及协调
    add_column :evaluation_user_capabilities, :project_management_coordination, :decimal, precision: 5, scale: 2
    add_column :archived_evaluation_user_capabilities, :project_management_coordination, :decimal, precision: 5, scale: 2
  end
end
