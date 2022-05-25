class ApplicationController < ActionController::API
        protect_from_forgery
        include DeviseTokenAuth::Concerns::SetUserByToken
end
