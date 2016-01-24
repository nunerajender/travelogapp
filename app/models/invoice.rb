class Invoice < ActiveRecord::Base

	belongs_to :product
	serialize :variants, Array

	enum status: {
		pending: 0,
		paid: 1,
		rejected: 2,
		refunded: 3
	}

	enum merchant_status: {
		initial: 0,
		accepted: 1,
		fullfilled: 2,
		cancelled: 3
	}

	belongs_to :user

	attr_accessor :price_with_currency
	attr_accessor :current_currency
	attr_accessor :currency_rate

	def get_merchant_status
		status = 'Pending'
		if self.accepted?
			status = "Accepted"
		elsif self.fullfilled?
			status = "Fullfilled"
		elsif self.cancelled?
			status = "Cancelled"
		end
		status
	end
end
