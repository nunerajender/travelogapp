class UsersController < ApplicationController
	skip_before_action :authenticate_user!

	def become_merchant
		if user_signed_in?
			if current_user.status != 'merchant'
			else
				redirect_to root_path
			end	
		else
			redirect_to new_user_registration_path
		end
		
	end
end
