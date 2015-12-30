class Product < ActiveRecord::Base
	
	
	belongs_to :user
	belongs_to :product_category
	belongs_to :location
	has_many :product_attachments, dependent: :destroy
	accepts_nested_attributes_for :product_attachments, allow_destroy: true
	has_many :variants, dependent: :destroy
	accepts_nested_attributes_for :variants, reject_if: proc { |attributes| attributes['name'].blank? }

	enum payment_type: {
		visa: 0,
		master: 1,
		american_express: 2,
		paypal: 3
	}

	attr_accessor :product_overview_url
	attr_accessor :user_avatar_url

	validates :name, :presence => true
	validates :product_category_id, :presence => true
	validates :description, :presence => true
	validates :highlight, :presence => true
	# validates :payment_type, :presence => true
	
end
