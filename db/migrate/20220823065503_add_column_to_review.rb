class AddColumnToReview < ActiveRecord::Migration[6.1]
  def change
    add_column :reviews, :image, :string
  end
end
