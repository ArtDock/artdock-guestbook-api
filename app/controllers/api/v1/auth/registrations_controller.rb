module Api
    module V1
      module Auth
        class RegistrationsController < DeviseTokenAuth::RegistrationsController
            private
            def sign_up_params
                params.permit(:name, :email, :password, :password_confirmation)
            end
  
            def account_update_params
                params.permit(:name, :role_id, :img)
                @role = Role.find(params[:role_id])
                user = User.find_by(email: request.headers[:HTTP_UID])
                @role.users << user
            end
        end
      end
    end
end