class RenameLikeColumn < ActiveRecord::Migration[7.1]
  def change
    rename_column :likes, :like, :like_value
  end
end
