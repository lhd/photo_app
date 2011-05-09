class SharesController < ApplicationController
  before_filter :preserve_own_image, :only => [:destroy]
  before_filter :accessible_share, :only => [:show]
  before_filter :own_image, :only => [:destroy]
      
  def new
  end
  
  def index

  end
  
  # shows all shares for a given image (param = @image.id) share_path(@image)
  def show
    @image = Image.find(params[:id])
    context_for_show
  end
  
  def create
    @share = Share.new
    @share.user_id = params[:user_id]
    @share.image_id = params[:image_id]
    @share.caused_by_friends = false
    if Share.where("user_id = #{@share.user_id} AND image_id = #{@share.image_id} AND caused_by_friends = FALSE").exists?
      flash[:error] = "This user already has access to the picture."
    elsif @share.save()
      
      # set image position as last
      @last_position = ImageOrder.where({:user_id => @share.user_id}).maximum('position')
      if @last_position
        @last_position += 1
      else
        @last_position = 0
      end
      @position = ImageOrder.create(:user_id => @share.user_id, :image_id => @share.image_id, :position => @last_position)
      
      
      flash[:success] = "User has now access."
    else
      flash[:error] = "Something went wrong, sorry."
    end
    @image = Image.find(params[:image_id])
    redirect_to "/shares/#{@share.image_id}"
  end
  
  def destroy
    @share = Share.find(params[:id])
    @share.destroy
    
    if !Share.exists?({:image_id => @share.image_id, :user_id => @share.user_id, :caused_by_friends => true})
      ImageOrder.destroy_all({:image_id => @share.image_id, :user_id => @share.user_id}) 
    end
    flash[:success] = "User no longer has access."
    context_for_show
    redirect_to "/shares/#{@image.id}"
  end
  
  private 
  
    def context_for_show
      @shares = Share.paginate(:page => params[:page], :per_page => 10, :conditions => ["image_id = #{@image.id} AND caused_by_friends = FALSE"], :order => 'created_at DESC')
      @users = users_by_email
      @owner = (@image.owner_id == current_user.id) 
      @share = Share.new 
    end
    
  def accessible_share
    begin
      @share = Share.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      flash[:notice] = "Sorry, you don't have access to this share."
      redirect_to(images_url)
    end
  end
  
    def preserve_own_image
      @share ||=  Share.find(params[:id])
      @image ||=  Image.find(@share.image_id)
      if @share.user_id == @image.owner_id
        flash[:notice] = "Can't remove access for the owner."
        context_for_show
        redirect_to "/shares/#{@image.id}"
      end
    end
    
    def own_image
      @share ||= Share.find(params[:id])
      @image ||= Image.find(@share.image_id)
      if current_user.id != @image.owner_id
        flash[:notice] = "Only the owner of the image is allowed to do that."
        context_for_show
        redirect_to "/shares/#{@image.id}"
      end      
    end
end
