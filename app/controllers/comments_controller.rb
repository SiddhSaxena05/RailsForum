class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post
  before_action :find_comment, only: [:edit, :update, :destroy]

  def new
    @comment = @post.comments.build
  end

  def create
    # Use transaction to ensure atomicity (ACID principle)
    ActiveRecord::Base.transaction do
      @comment = @post.comments.build(comment_params)
      @comment.user = current_user
      if @comment.save!
        redirect_to @post
      else
        render :new, status: :unprocessable_entity
        raise ActiveRecord::Rollback
      end
    end
  rescue ActiveRecord::RecordInvalid => e
    # Handle validation errors
    flash.now[:alert] = @comment.errors.full_messages.join(", ")
    render :new, status: :unprocessable_entity
  rescue ActiveRecord::StaleObjectError => e
    # Handle optimistic locking conflicts
    flash[:alert] = "The post was modified. Please refresh and try again."
    redirect_to @post
  end

  def edit
  end

  def update
    # Use transaction with optimistic locking (ACID: Atomicity + Consistency)
    ActiveRecord::Base.transaction do
      if @comment.update!(comment_params)
        redirect_to @post
      else
        render :edit, status: :unprocessable_entity
        raise ActiveRecord::Rollback
      end
    end
  rescue ActiveRecord::RecordInvalid => e
    # Handle validation errors
    flash.now[:alert] = @comment.errors.full_messages.join(", ")
    render :edit, status: :unprocessable_entity
  rescue ActiveRecord::StaleObjectError => e
    # Handle optimistic locking conflicts - reload to get latest version
    @comment.reload
    flash.now[:alert] = "This comment was modified by another user. Please review the changes and try again."
    render :edit, status: :conflict
  end

  def destroy
    # Use transaction to ensure atomicity (ACID principle)
    ActiveRecord::Base.transaction do
      @comment.destroy!
      flash[:notice] = "Comment deleted successfully"
      redirect_to @post
    end
  rescue ActiveRecord::RecordNotFound => e
    flash[:alert] = "Comment not found"
    redirect_to @post
  rescue ActiveRecord::StaleObjectError => e
    # Handle optimistic locking conflicts
    flash[:alert] = "This comment was modified. Please refresh and try again."
    redirect_to @post
  end

  private
    def comment_params
      params.require(:comment).permit(:content, :lock_version)
    end

    def set_post
      @post = Post.find(params[:post_id])
    end

    def find_comment
      @comment = @post.comments.find(params[:id])
    end
end