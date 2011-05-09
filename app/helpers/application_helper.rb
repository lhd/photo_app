module ApplicationHelper
  
  # Return a title on a per-page basis.
  def title
    base_title = "Photo App"
    if @title.nil?
      base_title
    else
      "#{base_title} | #{@title}"
    end
  end  
  
  def users_by_email
    User.all.sort! { |u1, u2| u1.email <=> u2.email }
  end
  
  def create_friend_shares_and_orders(image, user)
    Share.create({:caused_by_friends => true, :image_id => image.id, :user_id => user.id})
  
    # determine last image position and create/update order
    @last_position = ImageOrder.where({:user_id => user.id}).maximum('position')
    if @last_position
      @last_position += 1
    else
      @last_position = 0
    end
    @position = ImageOrder.where({:user_id => user.id, :image_id => image.id}).first
    if !@position
      @position = ImageOrder.create(:user_id => user.id, :image_id => image.id, :position => @last_position)
    else
      @position.position = @last_position
      @position.save
    end        
  end
  
  def destroy_friend_shares_and_orders(image, user)
    Share.destroy_all({:caused_by_friends => true, :image_id => image.id, :user_id => user.id})
    if !Share.exists?({:caused_by_friends => false, :image_id => image.id, :user_id => user.id})
      ImageOrder.destroy_all({:image_id => image.id, :user_id => user.id})
    end     
  end
end
