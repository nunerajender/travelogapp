class Product < ActiveRecord::Base
	
	
	belongs_to :user
	belongs_to :product_category
	has_many :product_attachments, dependent: :destroy
	accepts_nested_attributes_for :product_attachments

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
