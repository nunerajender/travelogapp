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
		if user_signed_in?
			@store_setting = StoreSetting.new(store_setting_params)
			@store_setting.user_id = current_user.id
			if params[:store_image].present? && params[:store_image][:id].present?
				store_image = StoreImage.find(params[:store_image][:id])
				if store_image.present?
					if @store_setting.save
						store_image.store_setting = @store_setting
						store_image.save
						# change status of the current user
						current_user.status = 'merchant'
						current_user.save
						UserMailer.welcome_merchant(current_user,@store_setting)
						redirect_to products_path
					end
				end
			else
				@store_setting.errors.add(:store_image, "can't be blank.")
				respond_to do |format|
	        format.html {render :become_merchant}
	        format.json {render json: { :errors => @store_setting.errors, :store_setting => @store_setting }, status: 422}
	      end
			end	
			
		end

	end

	private
		def store_setting_params
			params.require(:store_setting).permit(:phone_hp, :store_username, :store_name)
		end
end
