module Api
    module V1
      class UsersController < ApplicationController
        before_action :authenticate_api_v1_user!, only: [:update, :destroy]
        before_action :set_user, only: [:show, :update, :destroy, :events, :reviews]
        
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

        def events
          events = @user.events.order(start_date: :desc)
          events_response = []

          events.find_each do |event|
            events_response.append(event_response_public_format(event))
          end

          render json: {status: 'SUCCESS', message: 'Loaded user events', data: events_response}
        end

        def reviews
          reviews = @user.reviews.order(created_at: :desc).is_public
          render json: {status: 'SUCCESS', message: 'Loaded user reviews', data: reviews.as_json(include: [:event, :user])}
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

        def event_response_public_format(event)
          {
            "id": event.id,
            "user_id": event.user_id,
            "name": event.name,
            "description": event.description,
            "city": event.city,
            "country": event.country,
            "start_date": event.start_date,
            "end_date": event.end_date,
            "expiry_date": event.expiry_date,
            "year": event.year,
            "event_url": event.event_url,
            "virtual_event": event.virtual_event,
            "image": event.image,
            "event_template_id": event.event_template_id,
            "requested_codes": event.requested_codes,
            "private_event": event.private_event,
            "created_at": event.created_at,
            "updated_at": event.updated_at,
            "poap_event_id": event.poap_event_id,
            "status": event.status,
            "latitude": event.latitude,
            "longitude": event.longitude,
  
            "user": event.user,
            "reviews": event.reviews.is_public.as_json(include: :user) 
          }
        end
      end
    end
  end