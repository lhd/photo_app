class Image < ActiveRecord::Base
  has_many :comments, :dependent => :destroy
  has_many :shares
  has_many :users, :through => :shares
  has_many :image_orders

#  belongs_to :user
  attr_accessible :file, :remote_file_url, :file_cache, :remove_file, :title, :private, :global_access, :friends, :selected

  validates_presence_of :file
  validates_presence_of :title

  mount_uploader :file, ImageUploader  
end
