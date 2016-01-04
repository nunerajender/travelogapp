class Invoice < ActiveRecord::Base

	belongs_to :product
	serialize :variants, Array

	
end
