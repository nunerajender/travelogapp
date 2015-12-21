class StoreSetting < ActiveRecord::Base
	belongs_to :user

	mount_uploader :store_img, StoreImageUploader
end
