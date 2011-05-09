class UsersController < ApplicationController
  before_filter :authenticate, :only => [:edit, :update, :destroy, :show, :index]
  before_filter :correct_user, :only => [:edit, :update]
  before_filter :is_admin, :only => [:destroy]
  
  
  # GET /users
  def index
    @title = "All users"
    @users = User.paginate(:page => params[:page], :per_page => 5, :order => 'created_at DESC')
  end

  # GET /users/1
  # GET /users/1.xml
  def show
    begin
      @user = User.find(params[:id])
      @title = @user.name
    rescue ActiveRecord::RecordNotFound
      redirect_to(users_url)
    end    
  end


  def new
    @title = "Sign Up"
    @user = User.new

  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # POST /users
  def create
    @user = User.new(params[:user])

    if @user.save
      sign_in @user
      flash[:success] = "Welcome to the Sample App!"
      redirect_to(@user, :notice => 'User was successfully created.')
    else
      render 'new'
    end
  end

  # PUT /users/1
  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      flash[:success] = "Profile updated."
      redirect_to @user
    else
      @title = "Edit user"
      render 'edit'
    end
  end

  # DELETE /users/1
  def destroy
    @user = User.find(params[:id])
    @user.destroy
    flash[:success] = "User destroyed."
    redirect_to(users_path)
  end
  
  private

    def authenticate
      deny_access unless signed_in?
    end
  
    def correct_user
      @user = User.find(params[:id])
      redirect_to(users_path) unless current_user?(@user)
    end  

    def is_admin
      flash[:error] = "Only admins are allowed to delete users."
      redirect_to(users_path) unless current_user.admin?
    end  
end
