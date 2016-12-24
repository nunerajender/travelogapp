class TripsController < ApplicationController

	def layout_by_resource
		"product"
	end

	def index
		# @invoices = Invoice.where.not(:payer_id => nil)
		current_time = DateTime.now.strftime('%F')
		@upcomming_invoices = Invoice.includes(:product).where.not(:payer_id => nil).where("booking_date > ?", current_time).where(:user_id => current_user.id).order('booking_date desc')
		@previous_invoices = Invoice.includes(:product).where.not(:payer_id => nil).where("booking_date <= ?", current_time).where(:user_id => current_user.id).order('booking_date desc')
		set_product_attributs(@upcomming_invoices)
		set_product_attributs(@previous_invoices)
	end

	def update_status
		invoice = Invoice.find(params[:trip_id])
		status = params[:status]
		invoice.status = status
		invoice.save
		render :nothing => true, :status => 200, :content_type => 'text/html'
	end
	
	private
		def set_product_attributs(invoices)
      invoices.each do |invoice|
      	if invoice.product.product_attachments.present? && invoice.product.product_attachments.count
      		invoice.product.product_overview_url = invoice.product.product_attachments[0].attachment.medium.url
      	end
      	invoice.product.user_avatar_url = invoice.product.user.get_avatar_url
      end
    end

end
