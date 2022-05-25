class CreateRoleUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :role_users do |t|
      t.references :role, index: true, foreign_key: true
      t.references :user, index: true
      t.timestamps
    end
  end
end
