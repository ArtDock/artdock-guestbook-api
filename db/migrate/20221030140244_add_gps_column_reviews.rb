class AddGpsColumnReviews < ActiveRecord::Migration[6.1]
  def change
    add_column :reviews, :latitude, :decimal, :precision => 9, :scale => 6
    add_column :reviews, :longitude, :decimal, :precision => 9, :scale => 6
  end
end
