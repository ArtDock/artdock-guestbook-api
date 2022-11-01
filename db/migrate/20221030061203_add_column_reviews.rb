class AddColumnReviews < ActiveRecord::Migration[6.1]
  def change
    add_column :reviews, :is_deleted, :boolean, default: false, null: false
  end
end
