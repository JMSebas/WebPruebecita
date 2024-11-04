class AddGoogleCalendarFieldsToUsersAndEvents < ActiveRecord::Migration[7.2]
  def change
    add_column :events, :google_event_id, :string
    add_index :events, :google_event_id
    add_column :users, :google_token, :string
    add_column :users, :google_refresh_token, :string
    add_column :users, :token_expires_at, :datetime
  end
end
