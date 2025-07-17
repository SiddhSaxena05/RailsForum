class Post < ApplicationRecord
  validates :user_name, :content, :title, presence: true
end
