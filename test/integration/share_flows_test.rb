require 'test_helper'
 
class ShareFlowsTest < ActionController::IntegrationTest
  fixtures :all

  test "should make sure that a user can log in and shares can be added without adding duplicates" do
    get '/signin'
    assert_response :success
    assert_tag :tag => 'h1', :content => 'Sign in'

    post_via_redirect '/sessions', :session => {:email => 'firstuser@lhd-projects.com', :password => 'password'}
    assert_tag :tag => 'td', :attributes => {:class => 'main'}, :content => /firstuser/

    get '/shares/1'
    assert_response :success

    assert_tag :tag => 'table', :children => { :count => 1, :only => {:tag => 'tr', :content => /firstuser/ }}

    post_via_redirect '/shares', :image_id => 1, :user_id => 1
    assert_tag :tag => 'table', :children => { :count => 1, :only => {:tag => 'tr', :content => /firstuser/ }}
    assert_equal "This user already has access to the picture.", flash[:error]


    assert_tag :tag => 'table', :children => { :count => 0, :only => {:tag => 'tr', :content => /seconduser/ }}
    post_via_redirect '/shares', :image_id => 1, :user_id => 2
    assert_tag :tag => 'table', :children => { :count => 1, :only => {:tag => 'tr', :content => /seconduser/ }}
  end
end
