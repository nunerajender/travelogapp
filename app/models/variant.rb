class Variant < ActiveRecord::Base
	belongs_to :product

	attr_accessor :price_with_currency
end
