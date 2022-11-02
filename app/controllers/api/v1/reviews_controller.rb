module Api
    module V1
        class ReviewsController < ApplicationController
            before_action :authenticate_api_v1_user!, only: [:create, :update, :destroy, :my_review]
            around_action :set_scope
            before_action :set_review, only: [:show, :update, :destroy]
            before_action :gating, only: [:create, :update]

            def index
                reviews = Review.order(created_at: :desc).is_public
                reviews = reviews.includes(:event)
                reviews = reviews.includes(:user)
                render json: { status: 'SUCCESS', message: 'Loaded reviews', data: reviews.as_json(include: [:event, :user]) }
            end

            def show
                render json: { status: 'SUCCESS', message: 'Loaded the reviews', data: @review.as_json(include: [:event, :user]) }
            end

            def create
                if @gating_res_code == 200

                    if Review.exists?(user_id: current_api_v1_user.id, event_id: review_params[:event_id]) && !(review_params[:private])
                        render json: { status: 'ERROR', message: 'This user already reviewed this event', data: @gating_res_body }
                        return
                    else

                        if review_params[:image] != ""

                            require "google/cloud/storage"
                            uploaded_file = review_params[:image]
                            storage = Google::Cloud::Storage.new project: ENV["FIREBASE_PROJECT_ID"], keyfile: "#{Rails.root.to_s}/config/firebase-auth.json"
                            bucket = storage.bucket ENV["FIREBASE_STORAGE_BUCKET_ID"]
                            require "active_support/all"
                            file = bucket.create_file uploaded_file.path, metadata: { firebaseStorageDownloadTokens: SecureRandom.uuid }

                            review = Review.new(review_params.merge(user_id: current_api_v1_user.id, image: public_url(file)))
                        else
                            review = Review.new(review_params.merge(user_id: current_api_v1_user.id))
                        end
                       

                        if review.save
                            render json: { status: 'SUCCESS', data: review }
                            return
                        else
                            render json: { status: 'ERROR', data: review.errors }
                            return
                        end
                    end

                else
                    render json: { status: 'ERROR', message: @gating_message, data: @gating_res_body }
                    return
                end
            end

            def update
                if @review.user.id == current_api_v1_user.id
                    # imageの更新
                    if review_update_params[:image] != ""
                            
                        require "google/cloud/storage"
                        uploaded_file = review_update_params[:image]
                        storage = Google::Cloud::Storage.new project: ENV["FIREBASE_PROJECT_ID"], keyfile: "#{Rails.root.to_s}/config/firebase-auth.json"
                        bucket = storage.bucket ENV["FIREBASE_STORAGE_BUCKET_ID"]
                        require "active_support/all"
                        file = bucket.create_file uploaded_file.path, @review.image, metadata: { firebaseStorageDownloadTokens: SecureRandom.uuid }

                        review_update_params.merge(user_id: current_api_v1_user.id, image: public_url(file))
                    else
                        storage = Google::Cloud::Storage.new project: ENV["FIREBASE_PROJECT_ID"], keyfile: "#{Rails.root.to_s}/config/firebase-auth.json"
                        bucket = storage.bucket ENV["FIREBASE_STORAGE_BUCKET_ID"]
                        file = bucket.file(@review.image)
                        file.delete
                        review_update_params.merge(user_id: current_api_v1_user.id)
                    end


                    if @review.update(review_update_params)
                        render json: { status: 'SUCCESS', message: 'Updated the review', data: @review }
                    else
                        render json: { status: 'SUCCESS', message: 'Not updated', data: @review.errors }
                    end
                else
                  render json: { status: 'ERROR', message: 'Not permission', data: '' }
                end
            end

            def destroy
                if @review.user.id == current_api_v1_user.id
                    if @review.update(is_deleted: true)
                        render json: { status: 'SUCCESS', message: 'Deleted the review', data: @review }
                    else
                        render json: { status: 'SUCCESS', message: 'Not updated', data: @review.errors }
                    end
                else
                    render json: { status: 'ERROR', message: 'Not permission', data: '' }
                end
            end

            def my_review
                @user_reviews = Review.all.where(user_id: current_api_v1_user.id)
                render json: { status: 'SUCCESS', message: 'Loaded the reviews', data: @user_reviews.as_json(include: [:event, :user]) }
            end

            private

            def set_scope
                Review.where(is_deleted: false).scoping do
                    yield
                end
            end

            def set_review
                if request.headers[:uid] === Review.find(params[:id]).user.uid
                    @review = Review.find(params[:id])
                else
                    @review = Review.is_public.find(params[:id])
                end
            end

            def review_params
                params.permit(:event_id, :user_id, :body, :image, :private, :longitude, :latitude)
            end

            def review_update_params
                params.permit(:event_id, :body, :image, :private)
            end

            def public_url(file)
                # more like permanent
                URI(
                  "https://firebasestorage.googleapis.com/v0/b/#{CGI.escape file.bucket}/o/#{CGI.escape file.name}",
                ).tap do |uri|
              
                  uri.query = {
                    token: file.metadata["firebaseStorageDownloadTokens"],
                    alt: :media,
                  }.to_query
                end
            end

            def gating
                if review_params[:private]
                    @gating_res_code = 200
                    @gating_message = "Private review"
                    @gating_res_body = "Private review"
                else
                    require "net/http"
                    require "json"
                    wallet_address = current_api_v1_user.wallet_address
                    poap_event_id = Event.find(params[:event_id]).poap_event_id.to_s

                    uri = URI.parse("https://api.poap.tech/actions/scan/"+wallet_address+"/"+poap_event_id)
                    http = Net::HTTP.new(uri.host, uri.port)
                    http.use_ssl = uri.scheme === "https"

                    headers = { 
                        "X-API-Key" => ENV["X_API_Key"],
                        "Accept" => "application/json"
                    }

                    http.start do
                        req = Net::HTTP::Get.new(uri.request_uri)
                        req.initialize_http_header(headers)

                        res = http.request(req)
                        @gating_res_body = JSON.parse(res.body)
                        @gating_res_code = JSON.parse(res.code)
                        @gating_message = "Gating Failed"
                        if @gating_res_code == 200
                            puts res.code
                            @gating_message = "Gating Succeded"
                        end
                    end
                end  
            end
        end
    end
end
