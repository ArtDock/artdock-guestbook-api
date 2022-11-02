class CreateReviewShareHashes < ActiveRecord::Migration[6.1]
  def change
    create_table :review_share_hashes do |t|
      t.references :review, foreign_key: true
      t.string :hash_string
      
      t.timestamps
    end
  end
end
