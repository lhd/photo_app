class AddFriendsShareToShares < ActiveRecord::Migration
  def self.up
    add_column :shares, :caused_by_friends, :boolean
  end

  def self.down
    remove_column :shares, :caused_by_friends
  end
end
