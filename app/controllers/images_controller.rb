class ImagesController < ApplicationController
  before_filter :authenticate
  before_filter :accessible_image, :only => [:show]
  before_filter :own_image, :only => [:destroy]
    
  def index
    @title = "User images"
    @upper_limit = PhotoApp::Application::IMAGES_PER_PAGE
    @half_limit = PhotoApp::Application::IMAGES_PER_PAGE / 2
    
    # build select string according to access settings
    # - everyone has access
    # - selected users have access (so a share exists with cuased_by_friends = false)
    # - only the owner has access
    # - friends have access 
    @select_conditions = 'DISTINCT(images.id), images.file, image_orders.position'
    @where_conditions =  "image_orders.user_id = ? AND (
                          (images.selected = TRUE AND shares.image_id = images.id AND shares.user_id = ? AND shares.caused_by_friends = FALSE)
                          OR (images.private = TRUE AND images.owner_id = ?)
                          OR (images.friends = TRUE AND shares.image_id = images.id AND shares.user_id = ?))"

# TODO put global images on a separate page (Your libraray / Public library)
#    @global_images = Image.all(:conditions => ['images.global_access = TRUE'],
#                                :order => 'images.id')
    # get all images ordered by ImageOrder.position, then paginate
    @images = Image.all(:select => @select_conditions, 
                        :conditions => [@where_conditions, current_user.id, current_user.id, current_user.id, current_user.id], 
                        :joins => [:image_orders, :shares],
                        :order => 'image_orders.position'
                        ).paginate(:page => params[:page], :per_page => @upper_limit)
    @images_first_row = @images[0,@half_limit]
    @images_second_row = @images[@half_limit,@upper_limit]
    
    @page = params[:page] || 1
    @next_page = Image.all(:select => @select_conditions, 
                        :conditions => [@where_conditions, current_user.id, current_user.id, current_user.id, current_user.id], 
                        :joins => [:image_orders, :shares],
                        :order => 'image_orders.position'
                        ).paginate(:page => Integer(@page) + 1, :per_page => @upper_limit)
    @images_next_page = @next_page[0,@half_limit]    
  end

  def show
    @image = Image.find(params[:id])
    @comments = @image.comments
    @comment = Comment.new('text' => "Enter your comment...")
    @comment.user = current_user
    @comment.image = @image
    @title = @image.file.title
    
    # getting users for shares
    @users = users_by_email
    @share = Share.new
    @owner = (@image.owner_id == current_user.id)
  end
 
 
  def new
    @image = Image.new
    @title = "Upload Image"
  end


  # POST /images
  def create    
    begin
      @image = current_user.images.create(params[:image])    # unwise to use user.images anywhere else in this application, screwed up the table ;(
      @image.file = params[:file]
      @image.global_access = @image.friends = @image.private = false
      @image.selected = true  
      # set owner
      @image.owner_id = current_user.id 

      if @image.save 
        Share.update_all "caused_by_friends = FALSE", "user_id = #{current_user.id} AND image_id = #{@image.id} and caused_by_friends IS NULL"
        # set image position as last
        @last_position = ImageOrder.where({:user_id => current_user.id}).maximum('position')
        if @last_position
          @last_position += 1
        else
          @last_position = 0
        end

        @position = ImageOrder.create(:user_id => current_user.id, :image_id => @image.id, :position => @last_position)

        flash[:success] = "Upload successful."
        redirect_to(@image)
      else
        render 'new'
      end      
    rescue CarrierWave::DownloadError 
      flash[:error] = "Invalid URI, please check the image location."
      redirect_to(new_image_url)
    end
  end
 
  def update
    @image = Image.find(params[:id])
    @image.attributes = {"title" => params[:title]}
    if @image.save
      flash[:success] = "New title saved!"
    else
      flash[:error] = "Could not save the title."
    end
  end

  # TODO when adding a friend && one image has set "friends access", then add friends share + imageorder (or update it)
  # TODO-later what about: global preferences: friends should see ALL my images? - dont create shares but check whether user IN current_user.friends
  def access
    @image = Image.find(params[:id])
    @access = params[:access]
    @current_access = get_access_string_for(@image)

    if @access != @current_access

      set_access(@access)       # set new access settings  
      @image.save
      if @access != 'friends'   # change access data
        remove_friends_access
      else  # @access set to friends -> create share and create/update ImageOrder for each friend
        current_user.friends.each do | friend |
          create_friend_shares_and_orders(@image, friend)
        end
      end     
    end
    redirect_to @image
  end

  # DELETE /images/1
  def destroy
    @image = Image.find(params[:id])
#    @image.shares.destroy  
    Shares.destroy_all({:image_id => @image.id, :user_id => current_user.id})
    ImageOrder.destroy_all({:image_id => @image.id, :user_id => current_user.id})  
    @image.destroy
    redirect_to(images_url)
  end 

  private

    def authenticate
      deny_access unless signed_in?
    end
 
    def accessible_image
      begin
        @image = Image.find(params[:id])       
        if @image.global_access
          return
        elsif @image.private
          unless @image.owner_id == current_user.id then
            flash[:notice] = "Sorry, you don't have access to this image."
            redirect_to(images_url) 
          end
        elsif @image.selected
          unless Share.exists?(:user_id => current_user.id, :caused_by_friends => false, :image_id => @image.id) then
            flash[:notice] = "Sorry, you don't have access to this image."
            redirect_to(images_url)
          end
        elsif @image.friends
          unless  @image.users.include?(current_user) then
            flash[:notice] = "Sorry, you don't have access to this image."
            redirect_to(images_url) unless @image.users.include?(current_user)            
          end
        end   
      rescue ActiveRecord::RecordNotFound
        flash[:notice] = "Sorry, you don't have access to this image."
        redirect_to(images_url)
      end
    end
    
  def own_image
    begin
      @image = Image.find(params[:id])
      @owner = User.find(@image.owner_id)
      if @owner != current_user
        flash[:notice] = "Sorry, you're not allowed to do that."
        redirect_to(images_url)
      end
    rescue ActiveRecord::RecordNotFound
      flash[:notice] = "Sorry, this image doesn't exist."
      redirect_to(images_url)
    end
  end  
  
  def set_access(type)
    @image.attributes = {:private => false, :selected => false, :global_access => false, :friends => false} 
    @image.attributes = {type.to_sym => true}    
  end
  
  def get_access_string_for(image)
    if image.global_access
      return "global_access"
    elsif image.private
      return "private"
    elsif image.friends
      return "friends"
    elsif image.selected
      return "selected"
    end    
  end
  
  # TODO could reuse helper in app helper (iterate like in create_friends...as above)
  def remove_friends_access
    @friend_ids = current_user.friend_ids
    Share.destroy_all({:caused_by_friends => true, :image_id => @image.id, :user_id => @friend_ids})
    # delete image order IF no selected-share exists (cleanup dependent)
    current_user.friends.each do | friend |
      if !Share.exists?({:caused_by_friends => false, :image_id => @image.id, :user_id => friend.id})
        ImageOrder.destroy_all({:image_id => @image.id, :user_id => friend.id})
      end
    end    
  end
end
