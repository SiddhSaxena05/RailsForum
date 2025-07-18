class CreateCommentLikes < ActiveRecord::Migration[7.1]
  def change
    create_table :comment_likes do |t|
      t.string :user
      t.integer :like
      t.references :comment, null: false, foreign_key: true

      t.timestamps
    end
  end
end
