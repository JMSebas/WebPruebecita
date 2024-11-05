class RemoveTasksEventsAndUserFields < ActiveRecord::Migration[7.2]
 
  def change
    # Eliminar tablas
    drop_table :tasks, if_exists: true
    drop_table :events, if_exists: true

    # Eliminar columnas de la tabla users
    remove_column :users, :phone, :string, if_exists: true
    remove_column :users, :birthdate, :date, if_exists: true
    remove_column :users, :google_token, :string, if_exists: true
    remove_column :users, :google_refresh_token, :string, if_exists: true
  end
end
