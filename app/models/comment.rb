class Comment < ActiveRecord::Base
  belongs_to :image
  belongs_to :user
  attr_accessible :text
  validates :text, :presence     => true,
                   :length       => { :within => 3..255 }    
end
