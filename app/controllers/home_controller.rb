class HomeController < ApplicationController
	skip_before_action :authenticate_user!

	def index
	end

	# def search
	# 	render :template => "products/result"
	# end
end
