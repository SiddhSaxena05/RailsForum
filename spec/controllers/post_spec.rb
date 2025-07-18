require 'rails_helper'

RSpec.describe PostsController, type: :controller do
  fixtures :users, :posts
  let(:user) {users(:siddh)}
  let(:valid_post) {posts(:valid_post)}

  before do
    sign_in user
  end

  describe "GET #index" do
    it "returns a successful response for getting index" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #show" do
    it "returns a successful response for a valid post" do
      get :show, params: { id: valid_post.id }
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST #create" do
    context "with valid parameters" do
      it "creates a new post" do
        expect {
          post :create, params: { 
            post: { 
              title: "New Post", 
              content: "Content",
              user_id: user.id 
            } 
          }
        }.to change(Post, :count).by(1)
      end
    end
  end
end
