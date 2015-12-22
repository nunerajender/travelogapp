class UserAvatar < ActiveRecord::Base
	mount_uploader :avatar, AvatarUploader
end
