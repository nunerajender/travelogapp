class HomeController < ApplicationController
	skip_before_action :authenticate_user!

	def index

		@products = Product.where(:step => 5).limit(8)

		@products.each do |product|
			if product.currency != session[:currency]
	      rate = session["currency-convert-#{session[:currency]}"].to_f / session["currency-convert-#{product.currency}"].to_f
	    else
	      rate = 1.0
	    end

			product.price_with_currency = (product.price_cents * rate / 100).round(2)
			product.current_currency = session[:currency]
		end
		@product_attachments = ProductAttachment.all 
		#logger.info "status=Fetching Home Product image=#{@products.product_attachments.try(:first).attachment}" 

		countries = Product.select(:country).distinct.where("country is not null and country <> ''").pluck(:country)
		cities = Product.select(:city).distinct.where("city is not null and city <> ''").pluck(:city)
		# countries += cities
		gon.search_location_list = countries + cities
		gon.product_categories = ProductCategory.select(:name).pluck(:name)
	end

	# def search
	# 	render :template => "products/result"
	# end

end
