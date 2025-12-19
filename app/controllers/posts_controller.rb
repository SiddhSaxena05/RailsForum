class PostsController < ApplicationController
  before_action :set_post, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, except: [:index, :show]
  def index
    if params[:search].present?
      # Use exact match with case-insensitive comparison to leverage hash index
      # Hash indexes are optimized for equality (=) operations
      user = User.where("lower(email) = ?", params[:search].downcase).first
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
    # Use transaction to ensure atomicity (ACID principle)
    ActiveRecord::Base.transaction do
      @post = current_user.posts.build(post_params)
      if @post.save!
        redirect_to @post
      else
        render :new, status: :unprocessable_entity
        raise ActiveRecord::Rollback
      end
    end
  rescue ActiveRecord::RecordInvalid => e
    # Handle validation errors
    flash.now[:alert] = @post.errors.full_messages.join(", ")
    render :new, status: :unprocessable_entity
  rescue ActiveRecord::StaleObjectError => e
    # Handle optimistic locking conflicts
    flash[:alert] = "The post was modified. Please refresh and try again."
    redirect_to posts_path
  end

  def edit
  end

  def update
    # Use transaction with optimistic locking (ACID: Atomicity + Consistency)
    ActiveRecord::Base.transaction do
      if @post.update!(post_params)
        redirect_to @post
      else
        render :edit, status: :unprocessable_entity
        raise ActiveRecord::Rollback
      end
    end
  rescue ActiveRecord::RecordInvalid => e
    # Handle validation errors
    flash.now[:alert] = @post.errors.full_messages.join(", ")
    render :edit, status: :unprocessable_entity
  rescue ActiveRecord::StaleObjectError => e
    # Handle optimistic locking conflicts - reload to get latest version
    @post.reload
    flash.now[:alert] = "This post was modified by another user. Please review the changes and try again."
    render :edit, status: :conflict
  end

  def destroy
    # Use transaction to ensure atomicity (ACID principle)
    ActiveRecord::Base.transaction do
      delete_post = current_user.posts.find(params[:id])
      if delete_post.present?
        delete_post.destroy!
        flash[:notice] = "Post deleted successfully"
        redirect_to root_path
      else
        flash[:alert] = "You can't delete this post"
        redirect_to @post
        raise ActiveRecord::Rollback
      end
    end
  rescue ActiveRecord::RecordNotFound => e
    flash[:alert] = "Post not found"
    redirect_to posts_path
  rescue ActiveRecord::StaleObjectError => e
    # Handle optimistic locking conflicts
    flash[:alert] = "This post was modified. Please refresh and try again."
    redirect_to @post
  end

  private
    def set_post
      @post = Post.find(params[:id])
    end

    def post_params
      params.require(:post).permit(:title, :content)
    end
end