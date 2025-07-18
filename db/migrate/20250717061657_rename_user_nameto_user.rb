class RenameUserNametoUser < ActiveRecord::Migration[7.1]
  def change
    rename_column :posts, :user_name, :user
  end
end
