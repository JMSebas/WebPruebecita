class Task < ApplicationRecord
  belongs_to :project

  enum status: { pending: 1, in_process: 2, completed: 3}
end
