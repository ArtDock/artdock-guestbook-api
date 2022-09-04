module Api
    module V1
      class UsersController < ApplicationController
        before_action :authenticate_api_v1_user!, only: [:update, :destroy]
        before_action :set_user, only: [:show, :update, :destroy]
        
        def index
            users = User.order(created_at: :desc)
            render json: { status: 'SUCCESS', message: 'Loaded users', data: users }
        end
  
        def show
            role = @user.role_users.select(:role_id)
            role_name = []

            role.each do |data|
              role_id = data["role_id"]
              role_name.push(Role.find(role_id).role_name)
            end

            @user.role = role_name
            render json: { status: 'SUCCESS', message: 'Loaded the user', data: @user.as_json(include: :roles) }
        end

        def my_page
          render json: { status: 'SUCCESS', message: 'Loaded your data', data: current_api_v1_user.as_json(include: :roles) }
        end
  
        # def destroy
        #   @event.destroy
        #   render json: { status: 'SUCCESS', message: 'Deleted the event', data: @event }
        # end
  
        def update
          puts params[:id]
          puts current_api_v1_user.id
          if params[:id].to_i == current_api_v1_user.id
            if @user.update(user_update_params)
              render json: { status: 'SUCCESS', message: 'Updated the user', data: @user }
            else
              render json: { status: 'SUCCESS', message: 'Not updated', data: @user.errors }
            end
          else
            render json: { status: 'ERROR', message: '', data: '' }
          end
        end
  
        private
  
        def set_user
          @user = User.find(params[:id])
        end
  
        def user_update_params
          # logger.debug(current_api_v1_user)
          params.permit(:name, :wallet_address)
        end
      end
    end
  end