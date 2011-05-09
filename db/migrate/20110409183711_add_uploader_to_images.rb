class AddUploaderToImages < ActiveRecord::Migration
  def self.up
    add_column :images, :file, :string
  end

  def self.down
    remove_column :images, :file
  end
end
