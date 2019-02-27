class ApplicationController < ActionController::Base
	
	include SessionsHelper
	
	def hello
		render html: "It works!" 
	end
end
