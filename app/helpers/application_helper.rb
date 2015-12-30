module ApplicationHelper
	def site_name
		"Travelog.com"
	end

	def get_location_list
		countries = Product.select(:country).distinct.where("country is not null and country <> ''").pluck(:country)
		cities = Product.select(:city).distinct.where("city is not null and city <> ''").pluck(:city)
		countries += cities
	end
end
