require "test_helper"

class MapViewerControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get map_viewer_index_url
    assert_response :success
  end
end
