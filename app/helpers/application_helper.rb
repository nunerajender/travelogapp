require 'money'
require 'money/bank/google_currency'

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
		when 'PHP'
			ret = '$'
		when 'TWD'
			ret = 'NT$'
		end
		ret
	end

	def get_product_category_name(category_id)
    category = ProductCategory.find(category_id)
    category.name if category.present?
  end

  def get_country_list
  	ret = [{:country => 'Malaysia'}]
  end

  def get_currency_list
  	# ret = [{:currency => 'USD'}, {:currency => 'MYR'}, {:currency => 'SGD'}, {:currency => 'THB'}, 
  	# 			{:currency => 'PHP'}, {:currency => 'TWD'}]
  	ret = [{:currency => 'USD'}, {:currency => 'MYR'}, {:currency => 'SGD'}]
  end

  def get_all_currencies
  	# [ "USD", "MYR", "SGD", "THB", "PHP", "TWD" ]
  	[ "USD", "MYR", "SGD" ]
  end

  def get_all_currency_symbols
  	{ "USD" => "$", "MYR" => "RM", "SGD" => "SGD", "THB" => "฿", "PHP" => "₱", "TWD" => "NT$" }
  end

	def get_currency_rate(from_currency, to_currency)
		bank = Money::Bank::GoogleCurrency.new
		rate = bank.get_rate(from_currency, to_currency)
	end
end
