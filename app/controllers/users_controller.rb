class UsersController < ApplicationController
	skip_before_action :authenticate_user!, only:[:become_merchant]

	def become_merchant
		if user_signed_in?
			if current_user.status != 'merchant'
				@store_setting = StoreSetting.new({:user_id => current_user.id})
			else
				redirect_to root_path
			end	
		else
			redirect_to new_user_registration_path
		end
		
	end

	def complete_merchant
		
	end
end
