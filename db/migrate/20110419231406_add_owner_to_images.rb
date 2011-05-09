class AddOwnerToImages < ActiveRecord::Migration
  def self.up
    add_column :images, :owner_id, :integer
  end

  def self.down
    remove_column :images, :owner_id
  end
end
