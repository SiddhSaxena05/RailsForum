class DropCommentLikesPostLikes < ActiveRecord::Migration[7.1]
  def change
    drop_table :comment_likes
    drop_table :post_likes
    
  end
end
