class CreateJobRoles < ActiveRecord::Migration[7.1]
  def change
    create_table :job_roles do |t|
      t.string :st_code
      t.integer :job_level
      t.string :job_code
      t.string :job_family

      t.timestamps
    end
  end
end
