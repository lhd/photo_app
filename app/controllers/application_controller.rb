class ApplicationController < ActionController::Base
  protect_from_forgery
  include SessionsHelper
  include ApplicationHelper

  def search
    @search_type = params['searchtype']
    @search_term = params['searchterm']    
    @title = "Search results"
    
    if @search_type == 'images'
      @accessible_images = Image.all(:conditions => ['images.title LIKE ? AND shares.image_id = images.id AND shares.user_id = ?', "%#{@search_term}%", current_user.id],
                                    :joins => [:shares])
                                    
      # selects all images for which the current user has no access                             
      @inaccessible_images = Image.find_by_sql("select DISTINCT(images.id), images.title from images join shares s on images.id = s.image_id 
                                                where s.user_id != #{current_user.id} 
                                                AND images.title LIKE \"%#{@search_term}%\"
                                                AND (select count(shares.user_id) from shares
                                                where shares.user_id = #{current_user.id} AND shares.image_id = s.image_id) = 0")
      @share = Share.new
      render :file => '/images/search.html.erb', :layout => true
    elsif @search_type == 'users'
      @matching_users = User.where('name LIKE ? ', "%#{@search_term}%")
      render :file => '/users/search.html.erb', :layout => true
    else
      redirect_to root_url  
    end
  end

end
