class StoreSetting < ActiveRecord::Base
	belongs_to :user
	has_one :store_image

	validates :user_id, :presence => true
	validates :store_username, :presence => true, :uniqueness => true
	validates :store_name, :presence => true

end
