class AddUserDependancies < ActiveRecord::Migration[7.1]
  def change
    add_reference :posts, :user, null: true, foreign_key: true
    add_reference :comments, :user, null: true, foreign_key: true
    add_reference :post_likes, :user, null: true, foreign_key: true
    add_reference :comment_likes, :user, null: true, foreign_key: true
  end
end
