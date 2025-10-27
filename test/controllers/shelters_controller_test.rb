require "test_helper"

class SheltersControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get shelters_index_url
    assert_response :success
  end

  test "should get show" do
    get shelters_show_url
    assert_response :success
  end

  test "should get new" do
    get shelters_new_url
    assert_response :success
  end

  test "should get create" do
    get shelters_create_url
    assert_response :success
  end

  test "should get edit" do
    get shelters_edit_url
    assert_response :success
  end

  test "should get update" do
    get shelters_update_url
    assert_response :success
  end

  test "should get destroy" do
    get shelters_destroy_url
    assert_response :success
  end
end
