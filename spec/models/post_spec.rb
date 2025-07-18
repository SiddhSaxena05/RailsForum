require 'rails_helper'

RSpec.describe Post, type: :model do
  fixtures :users, :posts

  let(:valid_post) { posts(:valid_post) }

  it "valid with valid attributes" do
    expect(valid_post).to be_valid
  end

  it "is not valid without a valid user" do 
    valid_post.user_id = nil
    expect(valid_post).to_not be_valid
  end

  it "is not valid without a valid title" do
    valid_post.title = nil
    expect(valid_post).to_not be_valid
  end

  it "is not valid without valid content" do
    valid_post.content = nil
    expect(valid_post).to_not be_valid
  end

end
