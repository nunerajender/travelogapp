module ApplicationHelper
	def site_name
		"Travelog.com"
	end

	def get_location_list
		countries = Product.select(:country).distinct.where("country is not null and country <> ''").pluck(:country)
		cities = Product.select(:city).distinct.where("city is not null and city <> ''").pluck(:city)
		countries += cities
	end

	def get_currency_symbol(currency)
		ret = '$'
		case currency.upcase
		when 'USD'
			ret = '$'
		when 'MYR'
			ret = 'RM'
		when 'SGD'
			ret = '$'
		when 'THB'
			ret = '฿'
		when 'PHO'
			ret = '$'
		when 'TWD'
			ret = 'NT$'
		end
		ret
	end
end
