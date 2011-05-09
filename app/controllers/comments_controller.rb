class CommentsController < ApplicationController
  # POST /comments
  def create
    @comment = Comment.new(params[:comment])
    @comment.user = current_user
    @image = Image.find(params[:image_id])
    @comment.image = @image
    
    if @comment.save
      redirect_to(@image, :notice => 'Comment was successfully added.')
    else 
      error_string = "Comment \n"
      @comment.errors[:text].each do | msg |
        error_string += " - #{msg} \n" 
      end
      flash[:error] = error_string
      redirect_to(@image)
    end
  end

  # DELETE /comments/1
  # DELETE /comments/1.xml
  def destroy
    @comment = Comment.find(params[:id])
    @image = @comment.image  
    @comment.destroy

    redirect_to(@image, :notice => 'Comment removed')

  end
end
