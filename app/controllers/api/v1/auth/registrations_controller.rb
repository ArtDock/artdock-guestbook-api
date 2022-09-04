module Api
    module V1
      module Auth
        class RegistrationsController < DeviseTokenAuth::RegistrationsController
          # before_action :configure_account_update_params, only: [:update]
         
          private
          def sign_up_params
            params.permit(:name, :email, :password, :password_confirmation, :wallet_address)
          end
          
          def account_update_params
            params.permit(:name, :role_id, :img)
            @role = Role.find(params[:role_id])
            user = User.find_by(email: request.headers[:HTTP_UID])
            @role.users << user
          end

          # protected

          # def update_resource(resource, params)
          #   resource.update_without_password(params)
          # end

          # def configure_account_update_params
          #   devise_parameter_sanitizer.permit(:account_update, keys: [:distance])
          # end

          # def configure_account_update_params
          #   devise_parameter_sanitizer.permit(:account_update, keys: [:name])
          # end

        end
      end
    end
end