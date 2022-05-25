class CreateEvents < ActiveRecord::Migration[6.1]
  def change
    create_table :events do |t|
      t.references :user, foreign_key: true
      t.string :name
      t.text :description
      t.string :city
      t.string :country
      t.datetime :start_date
      t.datetime :end_date
      t.datetime :expiry_date
      t.integer :year
      t.string :event_url
      t.boolean :virtual_event
      t.string :image
      t.integer :secret_code
      t.integer :event_template_id
      t.string :email
      t.integer :requested_codes
      t.boolean :private_event
      t.timestamps
    end
  end
end
