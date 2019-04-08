require 'test_helper'

class SiteLayoutTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end

  def setup
  	@user = users(:yeiner)
  end

	test "layout links and friendly forwarding" do
		get root_path
		assert_template 'static_pages/home'
		assert_select "a[href=?]", root_path, count: 2
		assert_select "a[href=?]", help_path
		assert_select "a[href=?]", about_path
		assert_select "a[href=?]", contact_path
		assert_select "a[href=?]", login_path
		assert_select "a[href=?]", signup_path
		assert_select "a[href=?]", users_path, count: 0
		assert_select "a[href=?]", logout_path, count: 0
		get contact_path
		assert_select "title", full_title("Contact")
		get help_path
		assert_select "title", full_title("Help")
		get edit_user_path(@user)
		assert session[:forwarding_url] == request.original_url
		log_in_as @user
		assert_redirected_to edit_user_url(@user)
		get root_path
		assert_template 'static_pages/home'
		assert_select "a[href=?]", root_path, count: 2
		assert_select "a[href=?]", users_path
		assert_select	"a[href=?]", '#', text: "Account"
		assert_select	'ul.dropdown-menu'
		assert_select "a[href=?]", user_path(@user)
		assert_select "a[href=?]", edit_user_path(@user)
		assert_select "a[href=?]", logout_path
	end
end