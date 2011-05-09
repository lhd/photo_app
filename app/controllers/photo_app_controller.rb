class PhotoAppController < ApplicationController
  before_filter :authenticate, :only => [:galleries]
  before_filter :correct_user, :only => [:galleries]
  
  def home
    @title = "Home"
    @railsversion = Rails::VERSION::STRING
  end

  def galleries
    @title = "Galleries"
  end

  def contact
    @title = "Contact"
  end

  def help
    @title = "Help"
  end
  
  def upload
    @title = "Upload"
  end

  private

    def authenticate
      deny_access unless signed_in?
    end
  
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_path) unless current_user?(@user)
    end  
end
