class Invoice < ActiveRecord::Base

	belongs_to :product
	serialize :variants, Array

	enum status: {
		pending: 0,
		paid: 1,
		fullfilled: 2,
		cancelled: 3,
		completed: 4
	}

	# enum merchant_status: {
	# 	initial: 0,
	# 	accepted: 1,
	# 	fullfilled: 2,
	# 	cancelled: 3
	# }

	belongs_to :user

	attr_accessor :price_with_currency
	attr_accessor :current_currency
	attr_accessor :currency_rate

	attr_accessor :reward_credit_with_currency

	attr_accessor :real_total
	attr_accessor :real_total_with_currency

	# def get_merchant_status
	# 	status = 'Pending'
	# 	if self.accepted?
	# 		status = "Accepted"
	# 	elsif self.fullfilled?
	# 		status = "Fullfilled"
	# 	elsif self.cancelled?
	# 		status = "Cancelled"
	# 	end
	# 	status
	# end

	def get_merchant_status
		status = 'Pending'
		if self.paid?
			status = "Paid"
		elsif self.fullfilled?
			status = "Fullfilled"
		elsif self.cancelled?
			status = "Cancelled"
		end
		status
	end

	def get_merchant_available_status_list
		status_list = []
		if self.paid?
			status_list.push('fullfilled')
			status_list.push('cancelled')
		else
			status_list.push(self.status)
		end
		status_list
	end

	def get_guest_available_status_list
		status_list = []
		if self.fullfilled?
			status_list.push('completed')
		else
			status_list.push(self.status)
		end
		status_list
	end
end
