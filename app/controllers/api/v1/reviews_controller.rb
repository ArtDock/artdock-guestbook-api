module Api
    module V1
        class ReviewsController < ApplicationController
            before_action :authenticate_api_v1_user!, only: [:create, :update, :destroy, :my_review]
            before_action :set_review, only: [:show, :update, :destroy]

            def index
                reviews = Review.order(created_at: :desc).is_public
                reviews = reviews.includes(:event)
                reviews = reviews.includes(:user)
                render json: { status: 'SUCCESS', message: 'Loaded reviews', data: reviews.as_json(include: [:event, :user]) }
            end

            def show
                render json: { status: 'SUCCESS', message: 'Loaded the reviews', data: @review.as_json(include: [:event, :user]) }
            end

            # def review_check
            #     event_id = params[:event_id]
            #     if Review.exists?(user_id: current_api_v1_user.id, event_id: event_id)
            #         render json: { status: 'ERROR', message: 'Already reviewed', data: "false" }
            #     else
            #         render json: { status: 'SUCCESS', message: 'Not yet', data: "true" }
            #     end
            # end

            def my_review
                @user_reviews = Review.all.where(user_id: current_api_v1_user.id)
                render json: { status: 'SUCCESS', message: 'Loaded the reviews', data: @user_reviews.as_json(include: [:event, :user]) }
            end

            private

            def set_review
                @review = Review.is_public.find(params[:id])
            end
        end
    end
end
