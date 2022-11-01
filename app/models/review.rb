class Review < ApplicationRecord
  belongs_to :event, optional: true
  belongs_to :user

  scope :is_public, -> {where(private: false)}
  scope :is_private, -> {where(private: true)}
end
