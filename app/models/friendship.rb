class Friendship < ActiveRecord::Base
  belongs_to :friend1, :foreign_key => 'friend1', :class_name => 'User'
  belongs_to :friend2, :foreign_key => 'friend2', :class_name => 'User'
end
