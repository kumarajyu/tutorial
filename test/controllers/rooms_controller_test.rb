require 'test_helper'

class RoomsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get chat_url
    assert_response :success
  end

end
