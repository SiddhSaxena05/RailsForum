class RemoveUnusedTypes < ActiveRecord::Migration[7.1]
  def change
    remove_column :comment_likes, :user
    remove_column :comments, :user
    remove_column :post_likes, :user

  end
end
