class CreatePosts < ActiveRecord::Migration[7.1]
  def change
    create_table :posts do |t|
      t.string :user_name
      t.string :title
      t.string :content

      t.timestamps
    end
  end
end
