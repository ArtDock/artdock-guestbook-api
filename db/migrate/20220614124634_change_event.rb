class ChangeEvent < ActiveRecord::Migration[6.1]
  def change
    add_column :events, :latitude, :decimal,  :precision => 9, :scale => 6
    add_column :events, :longitude, :decimal,  :precision => 9, :scale => 6
  end
end
