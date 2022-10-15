class AddColumn < ActiveRecord::Migration[6.1]
  def change
    add_column :reviews, :private, :boolean, default: false, null: false
  end
end
