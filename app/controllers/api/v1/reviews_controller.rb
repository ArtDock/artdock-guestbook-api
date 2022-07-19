module Api
    module V1
        class ReviewsController < ApplicationController
            before_action :authenticate_api_v1_user!, only: [:create, :update, :destroy]
            before_action :set_review, only: [:show, :update, :destroy]

            def show
                render json: { status: 'SUCCESS', message: 'Loaded the reviews', data: @reviews }
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
                @event = Event.find(params[:id])
                @reviews = @event.reviews
            end

        end
    end
end
