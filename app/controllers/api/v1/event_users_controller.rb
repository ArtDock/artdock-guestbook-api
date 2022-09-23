module Api
    module V1
        class EventUsersController < ApplicationController
            before_action :set_user, only: [:show, :update, :destroy]

            def show
                @event = @user.events.order(start_date: "DESC")
                render json: { status: 'SUCCESS', message: 'Loaded the user', data: @event.as_json(include: [:user, reviews: {include: [:user]}]) }
            end

            private
  
            def set_user
                @user = User.find(params[:id])
            end
        end
    end
end
