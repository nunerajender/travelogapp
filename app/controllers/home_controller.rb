class HomeController < ApplicationController
	skip_before_action :authenticate_user!

	def index

		@products = Product.where(:step => 5).limit(6).includes(:product_attachments).includes(:product_reviews)

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
		gon.search_interests = ProductCategory.select(:name).pluck(:name)
		@search_location_list = countries + cities
		# gon.home_products = @products

		# count per city
		@count_per_city = {}
		get_all_cities.each do |city|
			@count_per_city[city] = Product.where(:step => 5).where("lower(city) LIKE ? or lower(country) like ?", "%#{city.downcase}%", "%#{city.downcase}%").count
		end
	end

	def home_products
		city = params[:city]
		if city.downcase == 'all cities'
			@products = Product.where(:step => 5).limit(6).includes(:product_attachments).includes(:product_reviews)
		else
			@products = Product.where(:step => 5).where("lower(city) LIKE ? or lower(country) like ?", "%#{params[:city].downcase}%", "%#{params[:city].downcase}%").limit(6)
		end
		
		@products.each do |product|
			if product.currency != session[:currency]
	      rate = session["currency-convert-#{session[:currency]}"].to_f / session["currency-convert-#{product.currency}"].to_f
	    else
	      rate = 1.0
	    end

			product.price_with_currency = (product.price_cents * rate / 100).round(2)
			product.current_currency = session[:currency]
		end
		# gon.home_products = @products
		# binding.pry
		render :layout => false
	end

	# def search
	# 	render :template => "products/result"
	# end

end
