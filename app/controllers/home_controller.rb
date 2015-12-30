class HomeController < ApplicationController
	skip_before_action :authenticate_user!

	def index

		@products = Product.all
		@product_attachments = ProductAttachment.all 
		#logger.info "status=Fetching Home Product image=#{@products.product_attachments.try(:first).attachment}" 

		countries = Product.select(:country).distinct.where("country is not null and country <> ''").pluck(:country)
		cities = Product.select(:city).distinct.where("city is not null and city <> ''").pluck(:city)
		# countries += cities
		gon.search_location_list = countries + cities
	end

	# def search
	# 	render :template => "products/result"
	# end

end
