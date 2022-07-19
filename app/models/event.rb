class Event < ApplicationRecord
    belongs_to :user
    has_many :reviews
    has_one :event_account
end
