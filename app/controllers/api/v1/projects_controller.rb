module Api
  module V1
    class ProjectsController < ApplicationController
      before_action :authenticate_user
      before_action :set_project, only: %i[show update destroy]

      def index
        @projects = current_user.projects
        render json: @projects
      end

      def show
        render json: @project.to_json(include: :tasks)
      end

      def create
        @project = current_user.projects.new(project_params)

        if @project.save
          # Si el proyecto se guarda exitosamente, creamos las tareas anidadas
          if params[:tasks].present?
            params[:tasks].each do |task_data|
              @project.tasks.create(task_params(task_data)) # Llama a task_params aquí
            end
          end

          # Respondemos con el proyecto y las tareas anidadas
          render json: { status: 200, message: 'Project and tasks created successfully', project: @project, tasks: @project.tasks }, status: :ok
        else
          render json: { status: 422, message: 'Project creation failed', errors: @project.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @project.update(project_params)
          render json: @project
        else
          render json: @project.errors, status: :unprocessable_entity
        end
      end

      def destroy
        if @project.destroy
          render json: { status: 200, message: 'Project deleted successfully' }, status: :ok
        else
          render json: { status: 404, message: 'Project not found' }, status: :not_found
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

      def set_project
        @project = current_user.projects.find_by(id: params[:id])
        unless @project
          render json: { status: 404, message: 'Project not found' }, status: :not_found
        end
      end

      def project_params
        params.require(:project).permit(:title, :description)
      end

      def task_params(task_data)
        task_data.permit(:title, :description, :status) # Permitir solo los atributos necesarios
      end
    end
  end
end
