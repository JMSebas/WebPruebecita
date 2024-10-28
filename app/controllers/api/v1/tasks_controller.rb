module Api
  module V1
    class TasksController < ApplicationController
      before_action :set_task, only: %i[show update destroy start_task finish_task]

      def index
        @tasks = Task.all
        render json: @tasks
      end

      def show
        render json: @task
      end

      def create
        @task = Task.new(task_params)
        @task.status = 'pending' # Establecemos el estado por defecto

        if @task.save
          render json: @task, status: :created  
        else
          render json: @task.errors, status: :unprocessable_entity
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

      # Nuevo método para iniciar la tarea
      def start_task
        if @task.update(status: 'in_process')
          render json: @task
        else
          render json: @task.errors, status: :unprocessable_entity
        end
      end

      # Nuevo método para finalizar la tarea
      def finish_task
        if @task.update(status: 'completed')
          render json: @task
        else
          render json: @task.errors, status: :unprocessable_entity
        end
      end

      private

      def set_task
        @task = Task.find(params[:id])
      end

      def task_params
        params.require(:task).permit(:title, :description, :status, :priority, :date, :user_id)
      end
    end
  end
end