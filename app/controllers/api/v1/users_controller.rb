# module Api
#     module V1
#         class UsersController < ApplicationController
#             def index
#                 users = User.find(1);
#                 render json: { status: 'SUCCESS', message: 'Loaded users', data: users.roles }
#               end
        
#               def show
#                 render json: { status: 'SUCCESS', message: 'Loaded the role', data: @role }
#               end
        
#               def create
#                 role = User.new(role_params)
#                 if role.save
#                   render json: { status: 'SUCCESS', data: role }
#                 else
#                   render json: { status: 'ERROR', data: role.errors }
#                 end
#               end
        
#               def destroy
#                 @role.destroy
#                 render json: { status: 'SUCCESS', message: 'Deleted the role', data: @role }
#               end
        
#               def update
#                 if @role.update(role_params)
#                   render json: { status: 'SUCCESS', message: 'Updated the role', data: @role }
#                 else
#                   render json: { status: 'SUCCESS', message: 'Not updated', data: @role.errors }
#                 end
#               end
        
#               private
        
#               def set_role
#                 @role = User.find(params[:id])
#               end
        
#               def role_params
#                 params.require(:role).permit(:title)
#               end
#         end
#     end
# end
