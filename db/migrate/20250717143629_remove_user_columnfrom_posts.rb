class RemoveUserColumnfromPosts < ActiveRecord::Migration[7.1]
  def change
    remove_column :posts, :user, :string
  end
end
