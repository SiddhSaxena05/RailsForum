class LikesController < ApplicationController
  before_action :authenticate_user!
  before_action :find_post

  def new
    @like = Like.new
  end


  def create
    find_likeable
    # if already_liked?
    #   flash[:alert] = "You have already liked this"
    # else
    @like = @likeable.likes.build(user: current_user, like_value: 1)
    @like.save
    # end
    redirect_to @post
  end

  def destroy
    find_like
    @like.destroy
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