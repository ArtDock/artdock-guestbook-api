module Api
    module V1
        class ReviewsController < ApplicationController
            before_action :authenticate_api_v1_user!, only: [:create, :update, :destroy]
            before_action :set_review, only: [:show, :update, :destroy]

            def index
                reviews = Review.order(created_at: :desc)
                reviews = reviews.includes(:event)
                reviews = reviews.includes(:user)
                render json: { status: 'SUCCESS', message: 'Loaded reviews', data: reviews.as_json(include: [:event, :user]) }
            end

            def show
                render json: { status: 'SUCCESS', message: 'Loaded the reviews', data: @user_reviews.as_json(include: :user) }
            end

            def review_check
                event_id = params[:event_id]
                if Review.exists?(user_id: current_api_v1_user.id, event_id: event_id)
                    render json: { status: 'ERROR', message: 'Already reviewed', data: "false" }
                else
                    render json: { status: 'SUCCESS', message: 'Not yet', data: "true" }
                end
            end

            private

            def set_review
                event_reviews = Review.where(event_id: params[:id])
                # @user_event = Event.eager_load(:events).find(params[:id])
                # @event_reviews = @user_event.events.pluck(:start_date).join(",")
                # @reviews = @user_event.events.eager_load(:reviews)
                # event_reviews[0].merge({"name" => 75})
                @user_reviews = event_reviews.includes(:user)

                @user_reviews.each do |review|
                    puts review.user.name
                end
            end
        end
    end
end
