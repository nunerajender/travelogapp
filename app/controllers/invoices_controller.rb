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
      param_variants.delete_if{|sa| sa.stringify_keys['count'].to_i == 0 }

      if param_variants.count > 0
        @invoice.variants = param_variants 
      end
      
      # binding.pry
      @product = Product.find(params["product-id"])
      @prodcut_image_url = @product.product_attachments[0].attachment.medium.url if @product.product_attachments.present? && @product.product_attachments.count > 0
      @invoice.currency = @product.currency

      # calculating the invoice amount cents from booking variant count.
      # binding.pry
      if param_variants.count > 0
        total_price_cents = 0
        param_variants.each do |variant|
          total_price_cents += variant["count"].to_i * variant["price_cents"].to_i
        end
        @invoice.amount_cents = total_price_cents
      else
        @invoice.amount_cents = @product.price_cents
      end
      gon.is_display_currency_exchange = false
  	end
  end

  def create

    @invoice = Invoice.new(invoice_params)
    param_variants = params[:variant]
    param_variants = [] if param_variants.blank?
    param_variants.delete_if{|sa| sa.stringify_keys['count'].to_i == 0 }
    
    if param_variants.count > 0
      @invoice.variants = param_variants 
    end
    paypal_options = {
      no_shipping: true, # if you want to disable shipping information
      allow_note: false, # if you want to disable notes
      pay_on_paypal: true # if you don't plan on showing your own confirmation step
    }
    # binding.pry
    request = Paypal::Express::Request.new(
      :username   => PAYPAL_CONFIG[:username],
      :password   => PAYPAL_CONFIG[:password],
      :signature  => PAYPAL_CONFIG[:signature]
    )
    payment_requests = []
    items = []
    if @invoice.variants.present? && @invoice.variants.count > 0
      seller_id = SecureRandom.hex(5)
      puts seller_id  
      @invoice.variants.each do |variant|
        
        request_id = SecureRandom.hex(5)
        puts request_id
        
        item_price = variant["price_cents"].to_i / 100
        item_count = variant["count"].to_i
        # payment_request = Paypal::Payment::Request.new(
        #   :currency_code => @invoice.currency,   # if nil, PayPal use USD as default
        #   :description   => variant["name"],    # item description
        #   :quantity      => item_count,      # item quantity
        #   :amount        => item_price * item_count,   # item value
        #   :seller_id => seller_id,
        #   :request_id => request_id
        # )

        # payment_requests << payment_request
        item = {
          :name => variant["name"],
          :description => variant["name"],
          :quantity      => item_count,
          :amount => item_price,
          :category => :Digital
        }
        items << item
      end
    else
      product = Product.find(params[:invoice][:product_id])
      item = {
        :name => product.name,
        :description => product.name,
        :quantity      => 1,
        :amount => product.price_cents / 100,
        :category => :Digital
      }
      items << item
    end

    payment_request = Paypal::Payment::Request.new(
      :currency_code => @invoice.currency,   # if nil, PayPal use USD as default
      :description   => 'booking travel',    # item description
      :quantity      => 1,      # item quantity
      :items => items,
      :amount        => @invoice.amount_cents / 100   # item value
    )
    # binding.pry
    
    response = request.setup(
      payment_request,
      invoices_success_checkout_url,
      invoices_cancel_checkout_url,
      paypal_options  # Optional
    )

    if response.ack == 'Success'
      
      @invoice.token = response.token
      @invoice.save!
      redirect_to response.redirect_uri
    else
      flash[:alert] = "There is an error while processing the payment"
      redirect_to product_url
    end

  end

  def success_checkout

    token = params[:token]
    payer_id = params[:PayerID]
    @invoice = Invoice.find_by_token(token)
    # binding.pry

    request = Paypal::Express::Request.new(
      :username   => PAYPAL_CONFIG[:username],
      :password   => PAYPAL_CONFIG[:password],
      :signature  => PAYPAL_CONFIG[:signature]
    )

    payment_request = Paypal::Payment::Request.new(
      :currency_code => @invoice.currency,   
      :description   => "New payment for travel booking",
      :quantity      => 1,
      :amount        => @invoice.amount_cents.to_i / 100
    )

    response = request.checkout!(
      params[:token],
      params[:PayerID],
      payment_request
    )

    gon.is_display_currency_exchange = false
    @currency_symbol = get_all_currency_symbols[@invoice.currency]

    if response.ack == 'Success'
      @invoice.update_attributes(:payer_id => payer_id, :status => "paid")      
      flash[:alert] = "Thanks for your submission."
    else
      flash[:alert] = "There is an error while processing the payment"
    end

    
    # inspect this attribute for more details
    # response.payment_info
  end

  def cancel_checkout
    gon.is_display_currency_exchange = false
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

    def invoice_params
      params.require(:invoice).permit(:billing_country, :payment_type, :valid_month, :valid_day, :security_code, 
        :billing_first_name, :billing_last_name, :billing_postal_code, :booking_date, :product_id, 
        :currency, :amount_cents)
    end
end
