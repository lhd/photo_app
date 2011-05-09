class AddFurtherAccessFlagsToImages < ActiveRecord::Migration
  def self.up
    add_column :images, :friends, :boolean
    add_column :images, :selected, :boolean
  end

  def self.down
    remove_column :images, :selected
    remove_column :images, :friends
  end
end
