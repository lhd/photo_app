class AddPrivateFlagToImages < ActiveRecord::Migration
  def self.up
    add_column :images, :private, :boolean
  end

  def self.down
    remove_column :images, :private
  end
end
