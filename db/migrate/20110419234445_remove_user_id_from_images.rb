class RemoveUserIdFromImages < ActiveRecord::Migration
  def self.up
    remove_column :images, :user_id
  end

  def self.down
    add_column :images, :user_id, :integer
  end
end
