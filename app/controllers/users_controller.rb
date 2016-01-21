class UsersController < ApplicationController
	skip_before_action :authenticate_user!, only:[:become_merchant]
	before_action :set_user_profile, only: [:profile, :profile_avatar, :profile_accounts]
	before_action :set_accounts, only: [:accounts, :accounts_photo]

	def layout_by_resource
    "product"
  end

  # click become merchant 
	def become_merchant

		if user_signed_in?
			if current_user.status != 'merchant'
				@store_setting = StoreSetting.new({:user_id => current_user.id})
				gon.store_usernames = StoreSetting.select(:store_username).pluck(:store_username)
				#UserMailer.welcome_merchant_message(current_user).deliver_now
				#puts "1----------------------"
			else
				redirect_to root_path
				#UserMailer.welcome_merchant_message(current_user).deliver_now
			end	
		else
			redirect_to new_user_registration_path
			#UserMailer.welcome_merchant_message(current_user).deliver_now
		end
	end

	def profile
		if request.get?
			@profile = Profile.new({:user_id => current_user.id}) if @profile.blank?
		else
			if @profile.blank?
				@profile = Profile.new(profile_params)
				@profile.user_id = current_user.id
				@profile.save
			else
				@profile.update(profile_params)
			end
			
			if params[:user][:new_password].present?
				current_user.password = params[:user][:new_password]
				current_user.save
			end

			redirect_to root_path
		end
	end

	def profile_avatar
		if request.get?
			@profile = Profile.new({:user_id => current_user.id}) if @profile.blank?
		else
			if params[:user_avatar].present? && params[:user_avatar][:id].present?
				user_avatar = UserAvatar.find(params[:user_avatar][:id])
				if @profile.save
					user_avatar.profile = @profile
					user_avatar.save
					redirect_to root_path
				end
			end
		end
	end

	def accounts
		if current_user.status != 'merchant'
			redirect_to root_path
		end
		if request.get?
			@store_setting = StoreSetting.new({:user_id => current_user.id}) if @store_setting.blank?
		else
			if @store_setting.update(store_setting_params)
				redirect_to root_path
			end
		end
	end

	def accounts_photo
		if current_user.status != 'merchant'
			redirect_to root_path
		end
		if request.get?
		else
			if params[:store_image].present? && params[:store_image][:id].present?
				store_image = StoreImage.find(params[:store_image][:id])
				if store_image.present?
					store_image.store_setting = @store_setting
					store_image.save
					redirect_to root_path
				end
			end	
		end
	end

	# complete become merchant
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
						#if verify_merchant_status
						#current_user.status = 'merchant'
					    #else
					    #current_user.status != 'merchant'
						#end

						current_user.save
						UserMailer.welcome_merchant_message(current_user, @store_setting).deliver_now
						#UserMailer.welcome_merchant(current_user,@store_setting)
						#redirect_to products_path
						redirect_to root_path
						flash[:notice] = "Your Merchant Application successfully created please wait for admin approvel"
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
	#verify merchant status
	#def verify_merchant_status
	#end

	# verify the store username for uniquness
	def verify_store_username
		store_setting = StoreSetting.where(:store_username => params[:store_username])
		if store_setting.blank?
			respond_to do |format|
				format.json { render json: {:result => true}}
			end
		else
			respond_to do |format|
				format.json { render json: {:result => false}}
			end
		end
	end

	private
		def store_setting_params
			params.require(:store_setting).permit(:phone_hp, :store_username, :store_name, :country, :city)
		end

		def profile_params
			params.require(:profile).permit(:first_name, :last_name, :gender)
		end

		def set_user_profile
			@profile = current_user.profile
		end

		def set_accounts
			@store_setting = current_user.store_setting
		end
end
