class Review < ApplicationRecord
  belongs_to :event, optional: true
  belongs_to :user
  has_one :review_share_hash

  scope :is_public, -> {where(private: false)}
  scope :is_private, -> {where(private: true)}
end
