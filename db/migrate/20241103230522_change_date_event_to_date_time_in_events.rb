class ChangeDateEventToDateTimeInEvents < ActiveRecord::Migration[7.2]
  def change
    change_column :events, :dateEvent, :datetime
  end
end
