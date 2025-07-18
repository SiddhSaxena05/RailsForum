class CreatePostLikes < ActiveRecord::Migration[7.1]
  def change
    create_table :post_likes do |t|
      t.string :user
      t.integer :like
      t.references :post, null: false, foreign_key: true

      t.timestamps
    end
  end
end
