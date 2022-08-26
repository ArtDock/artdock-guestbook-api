module Api
    module V1
        class PoapGatingController < ApplicationController
            before_action :authenticate_api_v1_user!
            before_action :gating

            def gating
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


            def gating_test
                if @gating_res_code == 200
                    render json: { status: 'SUCCESS', message: @gating_message, data: @gating_res_body }
                else
                    render json: { status: 'ERROR', message: @gating_message, data: @gating_res_body }
                end
            end

            def post_review
                if @gating_res_code == 200

                    if Review.exists?(user_id: current_api_v1_user.id, event_id: review_params[:event_id])
                        render json: { status: 'ERROR', message: 'This user already reviewed this event', data: @gating_res_body }
                    else
                        # FirebaseStorageへの保存
                        require "google/cloud/storage"
                        uploaded_file = params[:image]
                        storage = Google::Cloud::Storage.new project: ENV["FIREBASE_PROJECT_ID"], keyfile: ENV["FIREBASE_KEY_FILE"]
                        bucket = storage.bucket ENV["FIREBASE_STORAGE_BUCKET_ID"]
                        require "active_support/all"
                        file = bucket.create_file uploaded_file.path, metadata: { firebaseStorageDownloadTokens: SecureRandom.uuid }

                        review = Review.new(review_params.merge(user_id: current_api_v1_user.id, image: public_url(file)))

                        if review.save
                            render json: { status: 'SUCCESS', data: review }
                        else
                            render json: { status: 'ERROR', data: review.errors }
                        end
                    end

                else
                    render json: { status: 'ERROR', message: @gating_message, data: @gating_res_body }
                end
            end

            private

            def review_params
                params.permit(:event_id, :user_id, :body, :image)
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

        end
    end
end
