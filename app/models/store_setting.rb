class StoreSetting < ActiveRecord::Base
	belongs_to :user
	has_one :store_image, dependent: :destroy

	validates :user_id, :presence => true
	validates :store_username, :presence => true, :uniqueness => true
	validates :store_name, :presence => true


	def welcome_merchant_message(user,store)
    UserMailer.welcome_merchant_message(current_user).deliver_now
    end

end
