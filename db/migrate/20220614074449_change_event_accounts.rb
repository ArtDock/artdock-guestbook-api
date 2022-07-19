class ChangeEventAccounts < ActiveRecord::Migration[6.1]
  def change
    change_column :event_accounts, :code, :string
  end
end
