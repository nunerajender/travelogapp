class Product < ActiveRecord::Base
	mount_uploaders :attachments, AttachmentUploader
	
	belongs_to :user
	has_one :product_category

	enum payment_type: {
		visa: 0,
		master: 1,
		american_express: 2,
		paypal: 3
	}

	validates :name, :presence => true
	validates :product_category_id, :presence => true
	validates :payment_type, :presence => true
end
