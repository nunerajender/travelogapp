class HomeController < ApplicationController
	skip_before_action :authenticate_user!

	def index
		countries = Product.select(:country).distinct.where("country is not null and country <> ''").pluck(:country)
		cities = Product.select(:city).distinct.where("city is not null and city <> ''").pluck(:city)
		# countries += cities
		gon.search_location_list = countries + cities
	end

	# def search
	# 	render :template => "products/result"
	# end
end
