class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post
  before_action :find_comment, only: [:edit, :update, :destroy]

  def new
    @comment = @post.comments.build
  end

  def create
    ActiveRecord::Base.transaction do
      @comment = @post.comments.build(comment_params)
      @comment.user = current_user
      if @comment.save
        redirect_to @post
      else
        render :new, status: :unprocessable_entity
        raise ActiveRecord::Rollback
      end
    end
  rescue ActiveRecord::StaleObjectError => e
    # Handle optimistic locking conflicts
    flash[:alert] = "The post was modified. Please refresh and try again."
    redirect_to @post
  end

  def edit
  end

  def update
    ActiveRecord::Base.transaction do
      if @comment.update(comment_params)
        redirect_to @post
      else
        render :edit, status: :unprocessable_entity
        raise ActiveRecord::Rollback
      end
    end
  rescue ActiveRecord::StaleObjectError => e
    # Handle optimistic locking conflicts
    @comment.reload
    flash[:alert] = "This comment was modified by another user. Please review the changes and try again."
    render :edit, status: :conflict
  end

  def destroy
    ActiveRecord::Base.transaction do
      @comment.destroy
      flash[:notice] = "Comment deleted"
    end
    
    redirect_to @post
  rescue ActiveRecord::StaleObjectError => e
    # Handle optimistic locking conflicts
    flash[:alert] = "This comment was modified. Please refresh and try again."
    redirect_to @post
  end

  private
    def comment_params
      params.require(:comment).permit(:content)
    end

    def set_post
      @post = Post.find(params[:post_id])
    end

    def find_comment
      @comment = @post.comments.find(params[:id])
    end
end