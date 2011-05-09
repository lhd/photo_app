class CreateImageOrders < ActiveRecord::Migration
  def self.up
    create_table :image_orders do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :image_orders
  end
end
