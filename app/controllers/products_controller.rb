require 'money/bank/google_currency'
class ProductsController < ApplicationController
  before_action :set_product, only: [:show, :edit, :update, :destroy]

	def layout_by_resource
    "product"
  end

  def index
    if current_user.status == 'merchant'
      @products = Product.all
      @product_attachments = ProductAttachment.all  
    else
      redirect_to root_path
    end
  end

  def show
    @user = @product.user
    @other_products = Product.order('random()').limit(4)
    set_product_attributs(@other_products)

    gon.product_cover_image_url = @product.product_attachments.order('id')[0].attachment.url if @product.product_attachments.count > 0
    @is_variants = true if @product.variants.count > 0

    # get the currency rate

    # rates = {}
    # bank = Money::Bank::GoogleCurrency.new
    # get_all_currencies.each do |currency|
    #   puts("Product Currency: #{@product.currency.upcase}")
    #   puts("Product Currency: #{currency}")
    #   if @product.currency.upcase != currency
    #     rate = bank.get_rate(@product.currency.upcase, currency)
    #   else
    #     rate = 1.0
    #   end
    #   rates[currency] = rate
    # end
    
    # gon.currency_rates = rates

    if @product.currency != session[:currency]
      rate = session["currency-convert-#{session[:currency]}"].to_f / session["currency-convert-#{@product.currency}"].to_f
    else
      rate = 1.0
    end

    @product.price_with_currency = (@product.price_cents * rate / 100).round(2)
    @product.current_currency = session[:currency]
    @product.variants.each do |variant|
      variant.price_with_currency = (variant.price_cents * rate / 100).round(2)
    end

    @other_products.each do |product|
      if product.currency != session[:currency]
        rate = session["currency-convert-#{session[:currency]}"].to_f / session["currency-convert-#{product.currency}"].to_f
      else
        rate = 1.0
      end
      product.price_with_currency = (product.price_cents * rate / 100).round(2)
      product.current_currency = session[:currency]
    end

  end

  def new
    if current_user.status == 'merchant'
      @product = Product.new
      @categories = ProductCategory.all
      @product_attachment = @product.product_attachments.build
      @product_attachments = ProductAttachment.all
    else
      redirect_to root_path
    end
  end

  def create
  	@product = Product.new(product_params)
    @product.user = current_user
  	respond_to do |format|
      if @product.save

        param_variants = params[:variant]
        if param_variants.present?
          param_variants.delete_if{|sa| !sa.stringify_keys['name'].present? }
        else
          param_variants = []
        end
        
        if param_variants.count > 0
          param_variants.each do |param_variant|
            if param_variant[:name].present?
              variant = Variant.new
              variant.name = param_variant[:name]
              variant.price_cents = param_variant[:price_cents].to_i * 100
              variant.product = @product
              variant.save  
            end
          end
        end

        if params[:product_attachment].present?
          params[:product_attachment]['id'].each do |a|
            product_attachment = ProductAttachment.find(a)
            if product_attachment.present?
              product_attachment.product = @product
              product_attachment.save
            end
          end
        end
        

        # format.html { redirect_to @product, notice: 'product was successfully created.' }
        format.html { redirect_to products_path, notice: 'Product was successfully created.' }
        format.json { render :show, status: :created, location: @product }
      else
        format.html { render :new }
        # format.html { redirect_to products_path }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
    @categories = ProductCategory.all
  end

  # PATCH/PUT /products/1
  # PATCH/PUT /products/1.json
  def update
    respond_to do |format|
      if @product.update(product_params)
        @product.variants.delete_all

        param_variants = params[:variant]
        if param_variants.present?
          param_variants.delete_if{|sa| !sa.stringify_keys['name'].present? }
        else
          param_variants = []
        end
        
        if param_variants.count > 0
          base_price_cents = param_variants[0][:price_cents].to_i * 100
          param_variants.each do |param_variant|
            if param_variant[:name].present?
              variant = Variant.new
              variant.name = param_variant[:name]
              variant.price_cents = param_variant[:price_cents].to_i * 100
              if variant.price_cents < base_price_cents
                base_price_cents = variant.price_cents
              end
              variant.product = @product
              variant.save
            end
          end
          @product.price_cents = base_price_cents
          @product.save
        end
        if params[:product_attachment].present?
          params[:product_attachment]['id'].each do |a|
            product_attachment = ProductAttachment.find(a)
            if product_attachment.present?
              product_attachment.product = @product
              product_attachment.save
            end
          end
        end
        format.html { redirect_to products_path, notice: 'Product was successfully updated.' }
        format.json { render :show, status: :ok, location: @product_attachment }
      else
        format.html { render :edit }
        format.json { render json: @product_attachment.errors, status: :unprocessable_entity }
      end
    end
  end

  def result

    @is_search = true
    countries = Product.select(:country).distinct.where("country is not null and country <> ''").pluck(:country)
    cities = Product.select(:city).distinct.where("city is not null and city <> ''").pluck(:city)
    gon.search_location_list = countries + cities

    # @products = Product.where("name LIKE ? OR city LIKE ?", "%#{params[:name]}%", "%#{params[:city]}%")
    # str_query = 'product_category_id = -1'
    

    if params[:city].present?
      # str_query += " or (lower(city) LIKE '%#{params[:city].downcase}%' or lower(country) like '%#{params[:city].downcase}%')"
      @products = Product.where("lower(city) LIKE ? or lower(country) like ?", "%#{params[:city].downcase}%", "%#{params[:city].downcase}%")
      @city = params[:city]

      if params[:search_free_text].present?
        # str_query += " and (lower(name) LIKE %#{params[:search_free_text].downcase}%)"
        @products = @products.where("lower(name) LIKE ?", "%#{params[:search_free_text].downcase}%")
        @search_free_text = params[:search_free_text]
      end
    else
      @products = Product.all
    end
    
    # @products = Product.all if @products.blank?
    # @products = [] if @products.blank?
    # binding.pry
    # @products = Product.where(str_query)
    

    @categories = {}
    str_query = 'product_category_id = -1'
    temp_index = 0
    ProductCategory.order('id').each do |category|
      @categories["category_#{category.id}"] = params["category_#{category.id}"]
      if @categories["category_#{category.id}"].present? && @categories["category_#{category.id}"].to_i
        temp_index += 1
        str_query += " or product_category_id = #{category.id}"
      end
    end
    @products = @products.where(str_query)
    
    @total_count = @products.count
    @products = @products.page(params[:page]).per(8)
    set_product_attributs(@products)
  end

  def set_product_attributs(products)
    products.each do |product|
      if product.product_attachments.present? && product.product_attachments.count > 0
        product.product_overview_url = product.product_attachments[0].attachment.medium.url
      end
      product.user_avatar_url = product.user.get_avatar_url
    end
  end

  def result_filter
    @products = Product.all if @products.blank?
    @products = @products.page(params[:page]).per(8)
    @products.each do |product|
      if product.product_attachments.present? && product.product_attachments.count > 0
        product.product_overview_url = product.product_attachments[0].attachment.medium.url
      end
      product.user_avatar_url = product.user.get_avatar_url
    end
    render :result
  end

  # DELETE /products/1
  # DELETE /products/1.json
  def destroy
    @product.destroy
    respond_to do |format|
      format.html { redirect_to products_url, notice: 'Product was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  

  private
  	def set_product
      @product = Product.find(params[:id])
    end

  	def product_params
      op = params.require(:product).permit(:name, :product_category_id, :payment_type, :location_id, 
        :country, :address, :apt, :city, :state, :zip, :price_cents, :currency, :description, 
        :highlight, :refundable, :refund_day, :refund_percent, :variants_attributes => [:id, :name, :price_cents])
      op[:price_cents] = op[:price_cents].to_i * 100
      op
    end

end
