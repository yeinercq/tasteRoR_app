require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest

	def setup
		@user = users(:yeiner)
		@other_user = users(:andres)
	end

	test "login with invalid information" do
		get login_path
		assert_template 'sessions/new'
		post login_path, params: { session: { email: "", password: "" } }
		assert_template 'sessions/new'
		assert_not flash.empty?
		get root_path
		assert flash.empty?
	end

	test "login with valid information followed by logout" do
		get login_path
		post login_path, params: { session: { email: @user.email, password: 'password' } }
		assert is_logged_in?
		assert_redirected_to @user
		follow_redirect!
		assert_template 'users/show'
		assert_select "a[href=?]", login_path, count: 0
		assert_select "a[href=?]", logout_path
		assert_select "a[href=?]", user_path(@user)
		delete logout_path
		assert_not is_logged_in?
		assert_redirected_to root_url
		# Simulate a user clicking logout in  second window
		delete logout_path
		follow_redirect!
		assert_select "a[href=?]", login_path
		assert_select "a[href=?]", logout_path,      count: 0
		assert_select "a[href=?]", user_path(@user), count: 0
	end

	test "login with remembering" do
		log_in_as(@user, remember_me: '1')
		#assert_not_empty cookies[:remember_token] #test without user instance in session controller create method
		assert_equal cookies[:remember_token], assigns(:user).remember_token
	end

	test "login without remembering" do
		#Log in to set cookie
		log_in_as(@user, remember_me: '1')
		#Log in again and verify that the cookie is deleted
		log_in_as(@user, remember_me: '0')
		assert_empty cookies[:remember_token]
	end

	test "should redirect destroy when not logged in" do
		assert_no_difference 'User.count' do
			delete user_path(@user)
		end
		assert_redirected_to login_url
	end

	test "should redirect destroy when logged in as non-admin user" do
		log_in_as(@other_user)
		assert_no_difference 'User.count' do
			delete user_path (@user)
		end
		assert_redirected_to root_url
	end
end
