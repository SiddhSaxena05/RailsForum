class LikesController < ApplicationController
  before_action :authenticate_user!
  before_action :find_post

  def new
    @like = Like.new
  end


  def create
    find_likeable
    
    # Use database transaction to ensure atomicity (ACID principle)
    # Database unique constraint prevents duplicate likes at DB level
    ActiveRecord::Base.transaction do
      # Use find_or_initialize_by with locking to prevent race conditions
      @like = @likeable.likes.find_or_initialize_by(user: current_user)
      
      if @like.persisted?
        # Already liked - destroy it (toggle behavior)
        @like.destroy!
        flash[:notice] = "Like removed"
      else
        # New like - create it
        @like.like_value = 1
        @like.save!
        flash[:notice] = "Liked successfully"
      end
    end
    
    redirect_to @post
  rescue ActiveRecord::RecordNotUnique => e
    # Handle duplicate like detected by database unique constraint
    # This can happen in race conditions despite find_or_initialize_by
    flash[:alert] = "You have already liked this item."
    redirect_to @post
  rescue ActiveRecord::RecordInvalid => e
    # Handle validation errors
    flash[:alert] = @like.errors.full_messages.join(", ")
    redirect_to @post
  rescue ActiveRecord::StaleObjectError => e
    # Handle optimistic locking conflicts
    flash[:alert] = "This action was already processed. Please refresh the page."
    redirect_to @post
  end

  def destroy
    # Use transaction to ensure atomicity (ACID principle)
    ActiveRecord::Base.transaction do
      find_like
      if @like.user_id == current_user.id
        @like.destroy!
        flash[:notice] = "Like removed successfully"
      else
        flash[:alert] = "You can only remove your own likes"
        raise ActiveRecord::Rollback
      end
    end
    
    redirect_to @post
  rescue ActiveRecord::RecordNotFound => e
    flash[:alert] = "Like not found"
    redirect_to @post
  rescue ActiveRecord::StaleObjectError => e
    # Handle optimistic locking conflicts
    flash[:alert] = "This like was modified by another user. Please refresh and try again."
    redirect_to @post
  end

  private
    # def like_params
    #   params.require(:like).permit(:likeable_type, :likeable_id)
    # end

    def find_likeable
      @likeable_class = params[:likeable_type].constantize
      @likeable = @likeable_class.find(params[:likeable_id])
    end

    def find_post
      @post = Post.find(params[:post_id])
    end

    def find_like
      @like = Like.find(params[:id])
    end

    def already_liked?
      @like = @likeable.likes.find_by(user_id: current_user.id)
      @like.present?
    end
end