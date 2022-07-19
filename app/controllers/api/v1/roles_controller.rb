module Api
    module V1
        class RolesController < ApplicationController
            before_action :authenticate_api_v1_user!
            before_action :set_role,

            def set_user_role
              role = current_api_v1_user.role_users.select(:role_id)
              have_the_role = false
              return_data = "すでに登録されているロールです"

              role.each do |data|
                if data["role_id"] == params[:role_id]
                   have_the_role = true
                   puts have_the_role
                end
              end

              if !have_the_role
                @role.users << current_api_v1_user
                return_data = current_api_v1_user.role_users.select(:role_id)
              end

              render json: { status: 'SUCCESS', message: 'Set the role', data: return_data }
              
            end

            private
            def set_role
              params.permit(:role_id)
              @role = Role.find(params[:role_id])
            end
        end
    end
end
