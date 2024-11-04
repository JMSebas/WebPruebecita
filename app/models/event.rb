# app/models/event.rb
class Event < ApplicationRecord
  belongs_to :user
  
  validates :title, presence: true
  validates :description, presence: true
  validates :dateEvent, presence: true

  scope :upcoming, -> { where('date_event > ?', Time.current) }
  scope :due_now, -> { where('date_event <= ? AND date_event > ?', Time.current, 5.minutes.ago) }
end