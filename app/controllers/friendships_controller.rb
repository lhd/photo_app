class FriendshipsController < ApplicationController
  def index
    @title = "Friends"
    @friends = current_user.friends
  end

  # TODO i practically ruined the user/images-relation by adding another column to the table...
  # = crappy code, sorry.
  def add
    @friend = User.find(params[:id])
    if !Friendship.where({:friend1 => current_user, :friend2 => @friend}).exists?
      flash[:success] = "#{@friend.name} added to your friendslist."
      Friendship.create({:friend1 => current_user, :friend2 => @friend})
      Friendship.create({:friend2 => current_user, :friend1 => @friend})
      @friend_images = Image.where("images.owner_id = #{@friend.id}")  
      @friend_images.each do | image |  # sorry, can't use @friend.images because I was lazy...
        create_friend_shares_and_orders(image, current_user)
      end
      @current_user_images = Image.where("images.owner_id = #{current_user.id}")   
      @current_user_images.each do | image | # same here
        create_friend_shares_and_orders(image, @friend)
      end

    else 
      flash[:notice] = "#{@friend.name} is already your friend!"
    end
    redirect_to friendships_url
  end

  def create
  end

  def destroy
    @user = User.find(params[:id])
    @user_images = Image.where("images.owner_id = #{@user.id}")  
    @user_images.each do | image |
      destroy_friend_shares_and_orders(image, current_user)
    end
    @current_user_images = Image.where("images.owner_id = #{current_user.id}")
    @current_user_images.each do | image |
      destroy_friend_shares_and_orders(image, @user)
    end
    
    @user.friends.delete(current_user)
    current_user.friends.delete(@user)
    
    flash[:success] = "#{@user.name} is no longer your friend."
    redirect_to :action => 'index'
  end

end
