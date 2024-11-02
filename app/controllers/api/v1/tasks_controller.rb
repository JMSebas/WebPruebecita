module Api
  module V1
    class TasksController < ApplicationController
      before_action :set_task, only: %i[show update destroy start_task finish_task]
      before_action :authenticate_user

      def index
        @tasks = current_user.tasks # Solo obtiene las tareas del usuario autenticado
        render json: @tasks
      end

      def show
        render json: @task
      end

      def create
        task = current_user.tasks.new(task_params)
        task.status = "pending" # Crea la tarea asociada al usuario actual
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
        @task.destroy
        head :no_content
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
        if token.present?
          begin
            decoded_token = JWT.decode(token, Rails.application.credentials.fetch(:secret_key_base)).first
            @current_user = User.find(decoded_token['sub'])
          rescue JWT::DecodeError
            render json: { status: 401, message: 'Invalid or expired token' }, status: :unauthorized
          end
        else
          render json: { status: 401, message: 'Authorization header missing' }, status: :unauthorized
        end
      end

      def current_user
        @current_user
      end

      def set_task
        @task = current_user.tasks.find(params[:id]) # Asegúrate de que el usuario tiene acceso a la tarea
      end

      def task_params
        params.require(:task).permit(:title, :description, :priority, :date)
      end
    end
  end
end
