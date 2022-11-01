module Api
    module V1
        class PoapGatingController < ApplicationController
            before_action :authenticate_api_v1_user!
            before_action :gating


            def gating_test
                if @gating_res_code == 200
                    render json: { status: 'SUCCESS', message: @gating_message, data: @gating_res_body }
                else
                    render json: { status: 'ERROR', message: @gating_message, data: @gating_res_body }
                end
            end

            private

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

        end
    end
end
