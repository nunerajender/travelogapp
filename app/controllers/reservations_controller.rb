class ReservationsController < ApplicationController

	def layout_by_resource
		"product"
	end

	def index
		# current_time = DateTime.now.strftime('%F')
		# @upcomming_invoices = Invoice.includes(:product).where.not(:payer_id => nil).where("booking_date > ?", current_time).where(:user_id => current_user.id)
		# @previous_invoices = Invoice.includes(:product).where.not(:payer_id => nil).where("booking_date <= ?", current_time).where(:user_id => current_user.id)
		# set_product_attributs(@upcomming_invoices)
		# set_product_attributs(@previous_invoices)

		# Activity.joins(:locations).where('locations.country = "Australia"')

		@invoices = Invoice.joins(:product).where.not(:payer_id => nil).where("products.user_id = #{current_user.id}")
		set_product_attributs(@invoices)
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
