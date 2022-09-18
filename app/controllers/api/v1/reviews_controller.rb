module Api
    module V1
        class ReviewsController < ApplicationController
            before_action :authenticate_api_v1_user!, only: [:create, :update, :destroy]
            before_action :set_user_review, only: [:show, :update, :destroy]

            def index
                reviews = Review.order(created_at: :desc)
                reviews = reviews.includes(:event)
                reviews = reviews.includes(:user)
                render json: { status: 'SUCCESS', message: 'Loaded reviews', data: reviews.as_json(include: [:event, :user]) }
            end

            def show
                render json: { status: 'SUCCESS', message: 'Loaded the reviews', data: @user_reviews.as_json(include: [:event, :user]) }
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

            def set_user_review
                @user_reviews = Review.where(user_id: params[:id])
            end
        end
    end
end
