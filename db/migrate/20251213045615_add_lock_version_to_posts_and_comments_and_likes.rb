class AddLockVersionToPostsAndCommentsAndLikes < ActiveRecord::Migration[7.1]
  def change
    add_column :posts, :lock_version, :integer, default: 0, null: false
    add_column :comments, :lock_version, :integer, default: 0, null: false
    add_column :likes, :lock_version, :integer, default: 0, null: false
  end
end
