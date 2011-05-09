class CreateFriendships < ActiveRecord::Migration
  def self.up
    create_table :friendships do |t|
      t.integer :friend1
      t.integer :friend2

      t.timestamps
    end
  end

  def self.down
    drop_table :friendships
  end
end
