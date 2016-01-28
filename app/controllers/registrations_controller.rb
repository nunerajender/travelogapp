class RegistrationsController < Devise::RegistrationsController

	def create
		@user = User.build(user_params)
		@fb_share_token = params[:fb_share_token]

		if @fb_share_token.present?
			@inviter = User.find_by_fb_share_token(@fb_share_token)

			if @inviter.present?
				@user.is_fb_invited = true
				@user.reward_credit = 5
				@user.invited_by_id = @inviter.id
				@inviter.reward_credit += 5
			end

		end
		if @user.sign_up
			@inviter.save if @inviter.present?
			sign_in_and_redirect(:user, @user)
		else
			if @inviter.present?
				return redirect_to "/users/fbshare_accept?token=#{@fb_share_token}"
			else
				render 'registrations/new'
			end
		end

	end

	def new
		super
	end

	private

	def user_params
		params.require(:user).permit(:first_name,:last_name,:email,:password,:password_confirmation)
		
	end
end