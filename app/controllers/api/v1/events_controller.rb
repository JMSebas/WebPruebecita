module Api
  module V1
    class EventsController < ApplicationController
      before_action :authenticate_user
      before_action :set_event, only: %i[show update destroy]

      
      def index
        @events = current_user.events
        render json: @events
      end

      def show
        render json: @event
      end

      def check_due_events
        tolerance_in_minutes = 1
        current_time = Time.current.beginning_of_minute
      
        start_time = current_time - tolerance_in_minutes.minutes
        end_time = current_time + tolerance_in_minutes.minutes
      
        # Obtener el límite de eventos del parámetro de la solicitud, con un valor predeterminado
        limit = params[:limit] || 5
        due_events = Event.where(dateEvent: start_time..end_time).limit(limit)
      
        if due_events.present?
          render json: due_events, status: :ok
        else
          render json: { status: 404, message: "Event not found" }, status: :not_found
        end
      end
      
      
      


      def create
        event = current_user.events.new(event_params)

        if event.save
          render json: { status: 200, message: 'Event created successfully', event: event }, status: :ok
        else
          render json: { status: 422, message: 'Event creation failed', errors: event.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @event.update(event_params)
          render json: @event
        else
          render json: @event.errors, status: :unprocessable_entity
        end
      end

      def destroy
        begin
          if @event && @event.destroy
            render json: { status: 200, message: 'Event deleted successfully' }, status: :ok
          else
            render json: { status: 404, message: 'Event not found' }, status: :not_found
          end
        rescue => e
          render json: { status: 500, message: 'Error deleting event', error: e.message }, status: :internal_server_error
        end
      end

      private

      def authenticate_user
        token = request.headers['Authorization']&.split(' ')&.last

        unless token
          render json: { status: 401, message: 'Authorization header missing' }, status: :unauthorized
          return
        end

        begin
          decoded_token = JWT.decode(token, Rails.application.credentials.fetch(:secret_key_base)).first
          @current_user = User.find_by(id: decoded_token['sub'])

          unless @current_user
            render json: { status: 401, message: 'Invalid user' }, status: :unauthorized
            return
          end
        rescue JWT::DecodeError
          render json: { status: 401, message: 'Invalid or expired token' }, status: :unauthorized
          return
        rescue => e
          render json: { status: 500, message: 'Authentication error', error: e.message }, status: :internal_server_error
          return
        end
      end

      def current_user
        @current_user
      end

      def set_event
        begin
          @event = current_user.events.find_by(id: params[:id])
          unless @event
            render json: { status: 404, message: 'Event not found' }, status: :not_found
          end
        rescue => e
          render json: { status: 500, message: 'Error finding event', error: e.message }, status: :internal_server_error
        end
      end

      def event_params
        params.require(:event).permit(:title, :description, :dateEvent)
      end
    end
  end
end
