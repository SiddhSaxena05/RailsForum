class Post < ApplicationRecord
  belongs_to :user
  has_many :comments, dependent: :destroy
  has_many :likes, as: :likeable, dependent: :destroy
  validates :content, :title, presence: true
  
  # Optimistic locking enabled by lock_version column
  # Prevents concurrent update conflicts
end
