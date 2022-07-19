class CreateEventAccounts < ActiveRecord::Migration[6.1]
  def change
    create_table :event_accounts do |t|
      t.integer :event_id
      t.string :password_digest
      t.integer :code

      t.timestamps
    end
  end
end
