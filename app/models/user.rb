class User < ApplicationRecord
        # Include default devise modules.
        devise :database_authenticatable, :registerable,
                :recoverable, :rememberable, :trackable, :validatable
        #     :confirmable, :omniauthable
        include DeviseTokenAuth::Concerns::User
        has_many :role_users
        has_many :roles, through: :role_users
        has_many :events
        has_many :reviews
        # has_secure_password
        validates :name,  presence: true
        validates :email, presence: true, format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i }
        validates :password,  presence: true
end