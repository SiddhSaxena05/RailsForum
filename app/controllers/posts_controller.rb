class PostsController < ApplicationController
  before_action :set_post, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, except: [:index, :show]
  def index
    if params[:search].present?
      user = User.where("email ILIKE ?", "%#{params[:search]}%").first
      if user
        @posts = user.posts.includes(:user)
        @search_query = params[:search]
      else
        @posts = Post.none
        @search_query = params[:search]
        flash.now[:notice] = "No posts found for user: #{params[:search]}"
      end
    else
      @posts = Post.all.includes(:user)
    end
  end

  def show
    @comments = @post.comments
  end

  def new
    @post = current_user.posts.build
  end

  def create
    @post = current_user.posts.build(post_params)
    if @post.save
      redirect_to @post
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @post.update(post_params)
      redirect_to @post
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    delete_post = current_user.posts.find(params[:id])
    if (delete_post.presence)
      delete_post.destroy
      redirect_to root_path
    else
      flash[:alert] = "you can't delete this post"
      redirect_to @post
    end
    
  end

  private
    def set_post
      @post = Post.find(params[:id])
    end

    def post_params
      params.require(:post).permit(:title, :content)
    end
end