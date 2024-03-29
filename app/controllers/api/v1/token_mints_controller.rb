module Api
    module V1
        class TokenMintsController < ApplicationController
            before_action :authenticate_api_v1_user!
            # before_action :get_access_token
            def mint_to_user
                require "net/http"
                require "json"
                @access_token = "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6Ik5qQTNOalpGUWpkRE9ESTNRa0V3UlVSRE9VVkVNRVUxT1VVd1JrSTNNRGs1TlRORVFqUTNSUSJ9.eyJpc3MiOiJodHRwczovL3BvYXBhdXRoLmF1dGgwLmNvbS8iLCJzdWIiOiI2dUdYUUthOVpMRndLTnlHU1lRQW5sRkJFSVVDcUpmRUBjbGllbnRzIiwiYXVkIjoiYXJ0ZG9jayIsImlhdCI6MTY1NTE5MzM0MCwiZXhwIjoxNjU1Mjc5NzQwLCJhenAiOiI2dUdYUUthOVpMRndLTnlHU1lRQW5sRkJFSVVDcUpmRSIsInNjb3BlIjoibWludCIsImd0eSI6ImNsaWVudC1jcmVkZW50aWFscyIsInBlcm1pc3Npb25zIjpbIm1pbnQiXX0.jcU4QYcqbVBCXNsPJWvBvaaYBLv4s8XaC0N5dBx0mM6xO2Vb-C6xfhTwIx9AsZyOpygu9tvqGilO4ctlvX6K0TM7b88aeLZocgm68w3yqLbkbwPCOhYkQOrSeF1qe6LoXj50OKnJT3sO80KyQNyr9cSW9-Qgn2yCUmsDCYxRFoAoLI9KtZOGUcaH9HEZYZQr2fW2cNgzgXOK8C5ncCJKIDi_TFYZaamEzcrLIIJxmvvhBtYQFo0m59yJJ25G5vB-NP4BOlzi-PmdVolQZZ8eFi2YLid64J6Lhm_paUxWJ6AR7OJA5pf3pnddfbC0x0Xkyieg7BbU0dUsiFoZ8RjB_g"
                get_code_list(@access_token)
                get_mint_secret(@list_code, @access_token)
                mint_to_wallet(@mint_secret, @qr_hash, @access_token)
                render json: { status: 'SUCCESS', message: @mint_res_code, data: @mint_res_body }
            end

            private
  
            def get_access_token
                require "net/http"
                require "json"

                uri = URI.parse("https://poapauth.auth0.com/oauth/token")
                http = Net::HTTP.new(uri.host, uri.port)
                http.use_ssl = uri.scheme === "https"

                p = { 
                    audience: ENV["AUDIENCE"],
                    grant_type: ENV["GRANT_TYPE"],
                    client_id: ENV["CLIENT_ID"],
                    client_secret: ENV["CLIENT_SECRET"]
                }
                headers = { "Content-Type" => "application/x-www-form-urlencoded" }

                http.start do
                    req = Net::HTTP::Post.new(uri.path)
                    req.set_form_data(p)
                    req.initialize_http_header(headers)

                    res = http.request(req)
                    res_body = JSON.parse(res.body)
                    puts res_body["access_token"]
                    if res_body["access_token"].nil?
                        @access_token = "none"
                    else
                        @access_token = res_body["access_token"]
                    end
                end
            end

            def get_code_list(access_token)
                poap_event_id = Event.find(params[:event_id]).poap_event_id.to_s
                uri = URI.parse("https://api.poap.tech/event/"+poap_event_id+"/qr-codes")
                http = Net::HTTP.new(uri.host, uri.port)
                http.use_ssl = uri.scheme === "https"

                secret_code = Event.find(params[:event_id]).event_account.code

                puts Event.find(params[:event_id]).event_account.code

                p = {
                    secret_code: secret_code
                }
                headers = { 
                    "Content-Type" => "application/json",
                    "Authorization" => "Bearer " + access_token,
                    "X-API-Key" => ENV["X_API_Key"],
                    "Accept" => "application/json"
                }

                http.start do
                    req = Net::HTTP::Post.new(uri.path)
                    req.body = JSON.dump(p)
                    req.initialize_http_header(headers)

                    res = http.request(req)
                    res_body = JSON.parse(res.body)
                    @list_code = res_body
                end
            end

            def get_mint_secret(list_code, access_token)
                list_code.each do |data|
                    if !data["claimed"]
                        @qr_hash = data["qr_hash"]
                        break
                    end
                end

                uri = URI.parse("https://api.poap.tech/actions/claim-qr")
                p = {
                    "qr_hash" => @qr_hash
                }
                uri.query = URI.encode_www_form(p)
                http = Net::HTTP.new(uri.host, uri.port)
                http.use_ssl = uri.scheme === "https"

                headers = { 
                    "Authorization" => "Bearer " + access_token,
                    "Accept" => "application/json"
                }

                http.start do
                    req = Net::HTTP::Get.new(uri.request_uri)
                    req.initialize_http_header(headers)

                    res = http.request(req)
                    res_body = JSON.parse(res.body)
                    @mint_secret = res_body["secret"]
                end
            end

            def mint_to_wallet(mint_secret, qr_hash, access_token)
                uri = URI.parse("https://api.poap.tech/actions/claim-qr")
                http = Net::HTTP.new(uri.host, uri.port)
                http.use_ssl = uri.scheme === "https"

                p = {
                    "address": current_api_v1_user.wallet_address,
                    "qr_hash": qr_hash,
                    "secret": mint_secret
                }
                headers = { 
                    "Content-Type" => "application/json",
                    "Authorization" => "Bearer " + access_token,
                    "X-API-Key" => ENV["X_API_Key"],
                    "Accept" => "application/json"
                }

                http.start do
                    req = Net::HTTP::Post.new(uri.path)
                    req.body = JSON.dump(p)
                    req.initialize_http_header(headers)

                    res = http.request(req)
                    res_body = JSON.parse(res.body)
                    res_code = JSON.parse(res.code)
                    @mint_res_code = res_code
                    @mint_res_body = res_body
                end
            end

            def event_params
                params.require(:event_id).permit(:event_id)
            end

        end
    end
end
