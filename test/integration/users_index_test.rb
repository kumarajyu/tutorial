require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest

  def setup
    @admin     = users(:michael)
    @non_admin = users(:archer)
  end

  test "index as admin including pagination and delete links" do
    log_in_as(@admin)
    get users_path
    assert_template 'users/index'
    assert_select 'div.pagination'
    first_page_of_users = User.paginate(page: 1)
    first_page_of_users.each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name
      unless user == @admin
        assert_select 'a[href=?]', user_path(user), text: 'delete'
      end
    end
    assert_difference 'User.count', -1 do
      delete user_path(@non_admin)
    end
  end

  test "index as non-admin" do
    log_in_as(@non_admin)
    get users_path
    assert_select 'a', text: 'delete', count: 0
  end
  
  test "users search" do
  log_in_as(@admin)
  # All users
  get users_path, params: {q: {name_cont: ""}}
  User.paginate(page:1).each do |user|
  assert_select 'a[href=?]', user_path(user), text:user.name
  end
  

  # User search
  get users_path, params: {q: {name_cont: "a"}}
  q = User.ransack(name_cont: "a", activated_true: true)
  q.result.paginate(page:1).each do |user|
    assert_select 'a[href=?]', user_path(user), text:user.name
  end
  

  # User search (no result)
  get users_path, params: {q: {name_cont: "abcdefghijk"}}
  assert_match "Couldn't find any user.", response.body

  # Make sure the title is back to 'All users'
  get users_path, params: {q: {name_cont: ""}}
  
end
end