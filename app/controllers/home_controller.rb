class HomeController < ApplicationController
	skip_before_action :authenticate_user!

	def index
		@products = Product.all
		@product_attachments = ProductAttachment.all 
		#logger.info "status=Fetching Home Product image=#{@products.product_attachments.try(:first).attachment}" 
	end

	# def search
	# 	render :template => "products/result"
	# end

end
