module Api
  module V1
  class EventsController < ApplicationController
        before_action :set_event, only: %i[show update destroy]

        def index
          @events = Event.all
          render json: @events
        end

        def show
          render json: @event
        end

        def create
          @event = Event.new(event_params)

          if @event.save
            render json: @event, status: :created  
          else
            render json: @event.errors, status: :unprocessable_entity
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
          @event.destroy
          head :no_content
        end

        private

        def set_event
          @event = Event.find(params[:id])
        end

        def event_params
          params.require(:event).permit(:title, :description, :dateEvent, :user_id)
        end
    end
  end
end