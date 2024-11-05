module Api
  module V1
    class TasksController < ApplicationController
      before_action :authenticate_user
      before_action :set_task, only: %i[show update destroy start_task finish_task]

      def index
        @tasks = current_user.tasks
        render json: @tasks
      end

      def show
        render json: @task
      end

      def create
        task = current_user.tasks.new(task_params)
        task.status = "pending"
        if task.save
          render json: { status: 200, message: 'Task created successfully', task: task }, status: :ok
        else
          render json: { status: 422, message: 'Task creation failed', errors: task.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @task.update(task_params)
          render json: @task
        else
          render json: @task.errors, status: :unprocessable_entity
        end
      end

      def destroy
        begin
          if @task && @task.destroy
            render json: { status: 200, message: 'Task deleted successfully' }, status: :ok
          else
            render json: { status: 404, message: 'Task not found' }, status: :not_found
          end
        rescue => e
          render json: { status: 500, message: 'Error deleting task', error: e.message }, status: :internal_server_error
        end
      end

      def start_task
        if @task.update(status: 'in_process')
          render json: @task
        else
          render json: @task.errors, status: :unprocessable_entity
        end
      end

      def finish_task
        if @task.update(status: 'completed')
          render json: @task
        else
          render json: @task.errors, status: :unprocessable_entity
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

      def set_task
        begin
          @task = current_user.tasks.find_by(id: params[:id])
          unless @task
            render json: { status: 404, message: 'Task not found' }, status: :not_found
          end
        rescue => e
          render json: { status: 500, message: 'Error finding task', error: e.message }, status: :internal_server_error
        end
      end

      def task_params
        params.require(:task).permit(:title, :description, :priority, :date)
      end
    end
  end
end