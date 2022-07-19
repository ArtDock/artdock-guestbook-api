class RemPassToEventAccounts < ActiveRecord::Migration[6.1]
  def change
    remove_column :event_accounts, :password_digest, :string
  end
end
