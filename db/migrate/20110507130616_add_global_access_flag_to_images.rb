class AddGlobalAccessFlagToImages < ActiveRecord::Migration
  def self.up
    add_column :images, :global_access, :boolean
  end

  def self.down
    remove_column :images, :global_access
  end
end
