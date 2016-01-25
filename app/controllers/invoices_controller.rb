class InvoicesController < ApplicationController

	def layout_by_resource
    "product"
  end

  def index
    @invoices = Invoice.where.not(:payer_id => nil)
    current_time = DateTime.now.strftime('%F')
    @upcomming_invoices = Invoice.where.not(:payer_id => nil).where("booking_date > ?", current_time)
    @previous_invoices = Invoice.where.not(:payer_id => nil).where("booking_date <= ?", current_time)
  end

  def new
  	@invoice = Invoice.new
  	if request.post?
      
      @invoice.booking_date = params[:datepicker]
  		@invoice.product_id = params["product-id"]
  		param_variants = params[:variant]
      param_variants = [] if param_variants.blank?
      param_variants.delete_if{|sa| sa.stringify_keys['count'].to_i == 0 }

      # for cancel checkout
      @variant_params = param_variants.clone

      if param_variants.count > 0
        @invoice.variants = param_variants 
      end
      
      @product = Product.find(params["product-id"])
      @prodcut_image_url = @product.product_attachments[0].attachment.medium.url if @product.product_attachments.present? && @product.product_attachments.count > 0
      @invoice.currency = @product.currency

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
      @invoice_params = {}
      @contact_detail_params = {}
    else
      @invoice.booking_date = params[:invoice][:booking_date]
      @invoice.product_id = params[:invoice][:product_id]
      param_variants = params[:variant]
      param_variants = [] if param_variants.blank?
      param_variants.delete_if{|sa| sa.stringify_keys['count'].to_i == 0 }

      # for cancel checkout
      @variant_params = param_variants.clone

      if param_variants.count > 0
        @invoice.variants = param_variants 
      end
      
      # binding.pry
      @product = Product.find(params[:invoice][:product_id])
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
      @invoice_params = params[:invoice]
      gon.is_display_currency_exchange = false

      @contact_detail_params = params[:contact_detail]
  	end

    set_invoice_currency_attributes(@invoice)
  end

  def create

    @invoice = Invoice.new(invoice_params)
    @invoice.user = current_user
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
        item = {
          :name => variant["name"],
          :description => variant["name"],
          :quantity      => item_count,
          :amount => item_price,
          # :category => :Digital
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
        # :category => :Digital
      }
      items << item
    end

    payment_request = Paypal::Payment::Request.new(
      :currency_code => @invoice.currency,   # 
      :description   => 'booking travel',    # item description
      :quantity      => 1,      # item quantity
      :items => items,
      :amount        => @invoice.amount_cents / 100   # item value
    )

    # binding.pry

    begin
      response = request.setup(
        payment_request,
        invoices_success_checkout_url,
        # invoices_cancel_checkout_url,
        new_invoice_url(params),
        paypal_options  # Optional
      )

      if response.ack == 'Success'
        
        @invoice.token = response.token
        @invoice.save!

        contact_detail = ContactDetail.new(contact_detail_params)
        contact_detail.invoice = @invoice
        contact_detail.save!

        redirect_to response.redirect_uri
      else
        flash[:alert] = "There is an error while processing the payment"
        redirect_to product_url
      end  
    rescue Paypal::Exception::APIError => e
      # puts e.response for debugging.
      # binding.pry
      print(e.response.details)
      redirect_to new_invoice_url(params)
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
        :booking_date, :product_id, 
        :currency, :amount_cents)
    end

    def contact_detail_params
      params.require(:contact_detail).permit(:first_name, :last_name, :email, :phone_number, :message)
    end

    def set_invoice_currency_attributes(invoice)
      if invoice.currency != session[:currency]
        rate = (session["currency-convert-#{session[:currency]}"].to_f / session["currency-convert-#{invoice.currency}"].to_f).round(2)
      else
        rate = 1.0
      end
      invoice.price_with_currency = (invoice.amount_cents * rate / 100).round(2)
      invoice.current_currency = session[:currency]
      invoice.currency_rate = rate
    end
end
