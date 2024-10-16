class AddDetailsToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :name, :string
    add_column :users, :lastname, :string
    add_column :users, :address, :string
    add_column :users, :phone, :string
    add_column :users, :birthdate, :date
    add_column :users, :username, :string
  end
end
