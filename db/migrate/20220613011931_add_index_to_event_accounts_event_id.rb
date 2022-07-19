class AddIndexToEventAccountsEventId < ActiveRecord::Migration[6.1]
  def change
    add_index :event_accounts, :event_id, unique: true
  end
end
