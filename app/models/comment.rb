class Comment < ApplicationRecord
  has_many :likes, as: :likeable, dependent: :destroy
  belongs_to :post
  belongs_to :user

  validates :content, presence: true
  
  # Optimistic locking enabled by lock_version column
  # Prevents concurrent update conflicts
end
