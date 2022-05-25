class CreateReviews < ActiveRecord::Migration[6.1]
  def change
    create_table :reviews do |t|
      t.references :event, foreign_key: true
      t.references :user, foreign_key: true
      t.text :body
      t.timestamps
    end
  end
end
