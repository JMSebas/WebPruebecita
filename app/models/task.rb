class Task < ApplicationRecord
  belongs_to :user

  enum status: {pending: 1, in_process: 2, completed: 3}
  enum priority: {low: 1, medium: 2, high: 3, critical: 4}
end
