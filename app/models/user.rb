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
        validates :password,  presence: true, on: :create
        validates :password_confirmation, presence: true, on: :create

        # def update_without_current_password(params, *options)
        #         params.delete(:current_password)

        #         if params[:password].blank? && params[:password_confirmation].blank?
        #           params.delete(:password)
        #           params.delete(:password_confirmation)
        #         end
            
        #         result = update_attributes(params, *options)
        #         clean_up_passwords
        #         result
        # end
end