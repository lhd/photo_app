class AddColsToImageOrders < ActiveRecord::Migration
  def self.up
    add_column :image_orders, :image_id, :integer
    add_column :image_orders, :user_id, :integer
    add_column :image_orders, :position, :integer
  end

  def self.down
    remove_column :image_orders, :position
    remove_column :image_orders, :user_id
    remove_column :image_orders, :image_id
  end
end
