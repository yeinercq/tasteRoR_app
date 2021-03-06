require 'test_helper'

class MicropostsInterfaceTest < ActionDispatch::IntegrationTest
	def setup
		@user = users(:yeiner)
	end

	test "micropost interface" do
		log_in_as(@user)
		get root_path
		assert_select 'div.pagination'
		# Invalid submission
		assert_no_difference 'Micropost.count' do
			post microposts_path, params: { micropost: { content: "  " } }
		end
		assert_select 'div#error_explanation'
		assert_select 'input[type="file"]'
		# Valid submission
		content = "This micropost really ties the room together"
		picture = fixture_file_upload('test/fixtures/logoTasteProject.png', 'image/png')
		assert_difference 'Micropost.count', 1 do
			post microposts_path, params: { micropost: { content: content, picture: picture } }
		end
		micropost = assigns(:micropost) # assigns to access to micropost attributes
		assert micropost.picture?
		assert_redirected_to root_url
		follow_redirect!
		assert_match content, response.body
		# Delete post
		assert 'a', text: 'delete'
		first_micropost = @user.microposts.paginate(page: 1).first
		assert_difference 'Micropost.count', -1 do
			delete micropost_path(first_micropost)
		end
		# Visit different user (no delete links)
		get user_path(users(:jose))
		assert_select 'a', text: 'delete', count: 0
	end

	test "micropost sidebar count" do
		log_in_as(@user)
		get root_path
		assert_match "#{@user.microposts.count} microposts", response.body
		# With zero micropost
		other_user = users(:diana)
		log_in_as(other_user)
		get root_path
		assert "0 microposts", response.body
		other_user.microposts.create!(content: "A micropost")
		get root_path
		assert_match "1 micropost", response.body
	end
end
