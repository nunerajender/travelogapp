class InvoicesController < ApplicationController

	def layout_by_resource
    "product"
  end

  def new
  	@invoice = Invoice.new
  	if request.post?
  		@invoice.booking_date = params[:datepicker]
  		@invoice.product_id = params["product-id"]
  		param_variants = params[:variant]

  		param_variants = [] if param_variants.blank?

      # if param_variants.count > 0
      #   param_variants.each do |param_variant|
      #     if param_variant[:name].present?
      #       variant = Variant.new
      #       variant.name = param_variant[:name]
      #       variant.price_cents = param_variant[:price_cents].to_i * 100
      #       variant.product = @product
      #       variant.save  
      #     end
      #   end
      # end

      if param_variants.count > 0
        @invoice.variants = param_variants 
      end
      
      # binding.pry
      @product = Product.find(params["product-id"])
      @prodcut_image_url = @product.product_attachments[0].attachment.medium.url if @product.product_attachments.present? && @product.product_attachments.count > 0
  	end
  end

  def create
  end

  private
    def set_product_attributs(products)
      products.each do |product|
        if product.product_attachments.present? && product.product_attachments.count > 0
          product.product_overview_url = product.product_attachments[0].attachment.medium.url
        end
        product.user_avatar_url = product.user.get_avatar_url
      end
    end
end
