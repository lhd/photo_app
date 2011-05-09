require 'test_helper'

class SharesControllerTest < ActionController::TestCase
  def setup
    @user1 = User.find(1)
    @user2 = User.find(2)
    @image = Image.find(1)
    @number_of_shares = Share.count
  end

  
  def teardown
#    @share1.destroy
  end

  test "should not create a share if it already exists" do
    post :create, {:user_id => '1', :image_id => '1'}
    @new_number_of_shares = Share.count 
    assert_equal @number_of_shares, @new_number_of_shares
    assert_redirected_to '/shares/1'
  end

  test "should create a share if it doesn't exist yet" do
    assert_difference 'Share.count', +1 do
      post :create, {:user_id => '2', :image_id => '1'}
    end
    assert_redirected_to '/shares/1'
  end

  test "should delete a share so that it doesn't show on shares view" do
    assert_difference 'Share.count', -1 do
      delete :destroy, {:id => '1'}
    end
    assert_redirected_to '/shares/1'
  end
end
