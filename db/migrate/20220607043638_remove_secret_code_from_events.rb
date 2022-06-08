class RemoveSecretCodeFromEvents < ActiveRecord::Migration[6.1]
  def change
    remove_column :events, :secret_code, :integer
  end
end
