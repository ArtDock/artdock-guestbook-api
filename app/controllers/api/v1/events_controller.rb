module Api
  module V1
    class EventsController < ApplicationController
      before_action :set_event, only: [:show, :update, :destroy]

      def index
        events = Event.order(created_at: :desc)
        render json: { status: 'SUCCESS', message: 'Loaded events', data: events }
      end

      def show
        render json: { status: 'SUCCESS', message: 'Loaded the event', data: @event }
      end

      def create
        # event = Event.new(event_params)
        user_id = User.find(params[:user]).id
        event_params.delete('user')
        logger.debug "task1: #{event_params}"
        logger.debug "task2: #{user_id}"
        event = Event.new(event_params.merge(user_id: user_id))
        
        if event.save
          render json: { status: 'SUCCESS', data: event }
        else
          render json: { status: 'ERROR', data: event.errors }
        end
      end

      def destroy
        @event.destroy
        render json: { status: 'SUCCESS', message: 'Deleted the event', data: @event }
      end

      def update
        if @event.update(event_params)
          render json: { status: 'SUCCESS', message: 'Updated the event', data: @event }
        else
          render json: { status: 'SUCCESS', message: 'Not updated', data: @event.errors }
        end
      end

      private

      def set_event
        @event = Event.find(params[:id])
      end

      def event_params
        params.require(:event).permit(:user, :name, :description, :city, :country, :start_date, :end_date, :expiry_date, :year, :event_url, :virtual_event, :image, :secret_code, :event_template_id, :email, :requested_codes, :private_event)
      end
    end
  end
end