class ImageOrdersController < ApplicationController

  # PUT /image_orders/1
  # PUT /image_orders/1.xml
  def update
    @order = params[:image]
    
    # delete old order and save new order (for the images on the current page!)
    ImageOrder.destroy_all(:user_id => current_user.id, :image_id => @order)

    @page = Integer(params[:page]) - 1 
    @offset = 0 + 15 * @page  # TODO make parameter for images/page global / dependent on the others (calculate)
    @index = 0
    @order.each { | image_id |
      @position = @index + @offset
      ImageOrder.create(:user_id => current_user.id, :image_id => image_id, :position => @position)
      @index += 1
    }
    redirect_to images_path
  end
end
