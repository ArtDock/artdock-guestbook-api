class CreateRoles < ActiveRecord::Migration[6.1]
  def change
    create_table :roles do |t|
      t.string :role_name
      t.integer :user_id
      t.timestamps
    end
  end
end
