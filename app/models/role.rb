class Role < ApplicationRecord
  has_many :role_users, dependent: :destroy
  has_many :users, through: :role_users
  accepts_nested_attributes_for :role_users, allow_destroy: true
end
