class RenameCommentFields < ActiveRecord::Migration[7.1]
  def change
    rename_column :comments, :comment, :content
  end
end
