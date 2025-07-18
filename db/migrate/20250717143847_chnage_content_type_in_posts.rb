class ChnageContentTypeInPosts < ActiveRecord::Migration[7.1]
  def change
    change_column :posts, :content, :text
  end
end
