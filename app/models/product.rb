class Product < ActiveRecord::Base
	
	belongs_to :user
	belongs_to :product_category
	belongs_to :location
	has_many :product_attachments, dependent: :destroy
	accepts_nested_attributes_for :product_attachments, allow_destroy: true
	has_many :variants, dependent: :destroy
	accepts_nested_attributes_for :variants, reject_if: proc { |attributes| attributes['name'].blank? }

	after_initialize :init

	has_many :product_reviews

	enum payment_type: {
		visa: 0,
		master: 1,
		american_express: 2,
		paypal: 3
	}

	enum step: {
		basic: 0,
		description: 1,
		location: 2,
		photo: 3,
		price: 4,
		complete: 5
	}

	attr_accessor :product_overview_url
	attr_accessor :user_avatar_url

	attr_accessor :store_logo_url

	attr_accessor :price_with_currency
	attr_accessor :current_currency

	attr_accessor :review_mark

	validates :name, :presence => true
	validates :product_category_id, :presence => true
	# validates :description, :presence => true
	# validates :highlight, :presence => true
	# validates :payment_type, :presence => true
	

	def init
		self.currency = 'MYR'
	end
end
