module Api
  module V1
    class EventsController < ApplicationController
      before_action :set_event, only: [:show, :update, :destroy]

      def index
        events = Event.order(created_at: :desc)
        events = events.includes(:user)
        render json: { status: 'SUCCESS', message: 'Loaded events', data: events.as_json(include: [:user, :reviews]) }
      end

      def show
        render json: { status: 'SUCCESS', message: 'Loaded the event', data: @event.as_json(include: [:user, :reviews]) }
      end

      def create
        create_poap_event()
        # event = Event.new(event_params)

        # user_id = User.find(params[:user].to_i).id
        # event_params.delete('user')
        # puts params[:user]
        # logger.debug "task1: #{event_params}"
        # logger.debug "task2: #{user_id}"
        # event = Event.new(event_params.merge(user_id: user_id))

        # if event.save
        #   render json: { status: 'SUCCESS', data: event }
        # else
        #   render json: { status: 'ERROR', data: event.errors }
        # end

        render json: { status: 'SUCCESS', message: @create_res_code, data: @create_res_body }
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
      # 変数の定義
      def set_event
        @event_user = Event.joins(:user)
        puts @event_user
        @event = @event_user.find(params[:id])
      end

      # 必要なパラメータと許可するパラメータ
      def event_params
        params.require(:event).permit(:user, :name, :description, :city, :country, :start_date, :end_date, :expiry_date, :year, :event_url, :virtual_event, :image, :secret_code, :event_template_id, :email, :requested_codes, :private_event)
      end

      def create_poap_event()
        require "net/http"
        require "uri"
        require 'base64'

        uri = URI("https://api.poap.tech/events")
        https = Net::HTTP.new(uri.host, uri.port)
        # https.use_ssl = uri.scheme === "https"
        https.use_ssl = true

        start_date = params[:start_date].to_date.strftime("%Y-%b-%d")
        end_date = params[:end_date].to_date.strftime("%Y-%b-%d")
        expiry_date = params[:expiry_date].to_date.strftime("%Y-%b-%d")

        uploaded_file = params[:image]
        # b64_uploaded_file = Base64.strict_encode64(File.read(uploaded_file.path))
        puts uploaded_file.content_type
        puts uploaded_file.original_filename

        form_data = [
          ['virtual_event', params[:virtual_event]],
          ['name', params[:name]],
          ['description', params[:description]],
          ['city', params[:city]],
          ['country', params[:country]],
          ['start_date', start_date],
          ['end_date', end_date],
          ['expiry_date', expiry_date],
          ['year', params[:year]],
          ['event_url', params[:event_url]],
          ['image', File.open(uploaded_file.path)],
          ['private_event', params[:private_event]],
          ['secret_code', params[:secret_code]],
          ['email', params[:email]],
          ['requested_codes', params[:requested_codes]]
        ]
        puts form_data
        # p = {
        #   "virtual_event": params[:virtual_event],
        #   "name": params[:name],
        #   "description": params[:description],
        #   "city": params[:city],
        #   "country": params[:country],
        #   "start_date": start_date,
        #   "end_date": end_date,
        #   "expiry_date": expiry_date,
        #   "year": params[:year],
        #   "event_url": params[:event_url],
        #   "image": params[:image],
        #   "private_event": params[:private_event],
        #   "secret_code": params[:secret_code],
        #   "email": params[:email],
        #   "requested_codes": params[:requested_codes]
        # }
        headers = { 
          "Content-Type" => "multipart/form-data;",
          "X-API-Key" => ENV["X_API_Key"],
          "Accept" => "application/json;"
        }

        https.start do
          req = Net::HTTP::Post.new(uri.path)
          req.set_form form_data, 'multipart/form-data'
          req.initialize_http_header(headers)

          res = https.request(req)
          res_body = JSON.parse(res.body)
          res_code = JSON.parse(res.code)
          @create_res_code = res_code
          @create_res_body = res_body
        end
      end
    end
  end
end