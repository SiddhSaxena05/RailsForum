class Like < ApplicationRecord
  belongs_to :user
  belongs_to :likeable, polymorphic: true
  
  # Optimistic locking for concurrent updates
  # This prevents lost updates when multiple users interact simultaneously
  
  # Validate uniqueness at application level (database has unique index as backup)
  validates :user_id, uniqueness: { 
    scope: [:likeable_type, :likeable_id],
    message: "has already liked this item"
  }
end
