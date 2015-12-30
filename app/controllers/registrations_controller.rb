class RegistrationsController < Devise::RegistrationsController

	def create
		@user = User.build(user_params)
		if @user.sign_up
			sign_in_and_redirect(:user, @user)
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