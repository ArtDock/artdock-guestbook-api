class AddPoapEventIdToEvents < ActiveRecord::Migration[6.1]
  def change
    add_column :events, :poap_event_id, :integer
    add_column :events, :status, :string
  end
end
