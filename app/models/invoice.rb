class Invoice < ActiveRecord::Base

	belongs_to :product
	serialize :variants, Array

	enum status: {
		pending: 0,
		paid: 1,
		rejected: 2,
		refunded: 3
	}
end
