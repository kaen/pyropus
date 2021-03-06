require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  include Authorization

  admin_action :new, :create, :edit, :update, :destroy, :show, :index

  setup do
    @input_attributes = {
      name: "fred",
      password: "password",
      password_confirmation: "password"
    }
    @user = users(:admin)
    log_in @user
    permission_test_params user: { name: 'hi', password_digest: 'ho', group_id: 2 }, id: @user.id
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:users)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create user" do
    assert_difference('User.count') do
      post :create, user: @input_attributes
    end

    assert_redirected_to user_path(assigns(:user))
  end

  test "should show user" do
    get :show, id: @user
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @user
    assert_response :success
  end

  test "should update user" do
    put :update, id: @user, user: @input_attributes
    assert_redirected_to user_path(assigns(:user))
  end

  test "should destroy user" do
    assert_difference('User.count', -1) do
      delete :destroy, id: @user
    end

    assert_redirected_to users_path
  end

end
