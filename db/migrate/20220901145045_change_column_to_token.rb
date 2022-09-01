class ChangeColumnToToken < ActiveRecord::Migration[6.1]
  def change
    change_column :tokens, :token, :string, :limit=>2000
  end
end
