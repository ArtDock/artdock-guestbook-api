module Api
    module V1
      module Auth
        class RegistrationsController < DeviseTokenAuth::RegistrationsController
            protect_from_forgery
            private
            def sign_up_params
                params.permit(:name, :role, :email, :password, :password_confirmation)
            end
  
            def account_update_params
                params.permit(:name, :role, :email, :img)
            end
        end
      end
    end
end