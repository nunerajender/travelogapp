require 'money/bank/google_currency'
class ProductsController < ApplicationController
  before_action :set_product, only: [:show, :edit, :update, :destroy, :write_comment]
  before_action :set_product_widget, only: [:edit_basic, :edit_description, :edit_location, :edit_photo, :edit_price]
  skip_before_action :authenticate_user!, only: [:result, :show]

	def layout_by_resource
    "product"
  end

  def index
    if current_user.status == 'merchant'
      @products = current_user.products

      @unlisted_products = @products.where.not(:step => 5)
      @listed_products = @products.where(:step => 5)

      # set_product_attributs(@products)
      set_product_attributs(@unlisted_products)
      set_product_attributs(@listed_products)
      
    else
      redirect_to root_path
    end
  end

  def show
    @user = @product.user
    @other_products = Product.where(:step => 5).order('random()').limit(4)
    set_product_attributs(@other_products)

    gon.product_cover_image_url = @product.product_attachments.order('id')[0].attachment.url if @product.product_attachments.count > 0
    @is_variants = true if @product.variants.count > 0

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

    set_product_currency_attributes(@other_products)
    @current_currency = get_all_currency_symbols[session[:currency]]

    # set params for product reivews
    if user_signed_in?
      @product_reviews = @product.product_reviews.where(:user_id => current_user.id)
      @product_reviews += @product.product_reviews.where.not(:user_id => current_user.id).order('user_id')  
    else
      @product_reviews = @product.product_reviews
    end
    
    @total_review_count = @product_reviews.count
    # @product_reviews = @product_reviews.page(params[:page]).per(10)
    @product_reviews = Kaminari.paginate_array(@product_reviews).page(params[:page]).per(10)
    @product_reviews.each do |product_review|
      product_review.set_avatar_url
    end
  end

  def write_comment
    message = params[:message]
    product_review = ProductReview.where(:user_id => current_user.id, :product_id => @product.id).first
    product_review = ProductReview.new({:user_id => current_user.id, :product_id => @product.id}) if product_review.blank?
    product_review.message = message
    product_review.rating_stars = params["rating-stars"].to_i
    if product_review.save
      product_name = @product.name
      # UserMailer.write_review(current_user, @product, message).deliver_now
      redirect_to product_path @product
    else
      redirect_to root_path
    end
    
  end

  def new
    if current_user.status == 'merchant'
      @product = Product.new
      @categories = ProductCategory.all
      @product_attachment = @product.product_attachments.build
      @product_attachments = ProductAttachment.all
      @show_section = 'basic'
      render :layout => 'product_new'
    else
      redirect_to root_path
    end
  end

  def create
  	@product = Product.new(product_params)
    @product.user = current_user
  	respond_to do |format|

      if params[:product].present?
        unless @product.save
          # format.html { render :new }
          format.html { redirect_to new_product_path }
          format.json { render json: @product_attachment.errors, status: :unprocessable_entity }
        end
      end
      
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
      

      step_param = params["step-param"]
      case step_param
      when "basic"
        if @product.step == 'basic'
          @product.step = 'description'
          @product.save
        end
        format.html { redirect_to edit_description_product_path @product }
        format.json { render :show, status: :ok, location: @product_attachment }
      when "description"
        format.html { redirect_to edit_location_product_path @product }
        format.json { render :show, status: :ok, location: @product_attachment }
      when "location"
        format.html { redirect_to edit_photo_product_path @product }
        format.json { render :show, status: :ok, location: @product_attachment }
      when "photo"
        format.html { redirect_to edit_price_product_path @product }
        format.json { render :show, status: :ok, location: @product_attachment }
      else
        format.html { redirect_to products_path }
        format.json { render :show, status: :ok, location: @product_attachment }
      end
      
    end
  end

  def edit
    # @categories = ProductCategory.all
    # render :layout => 'product_new'
    case @product.step
    when 'basic'
      redirect_to edit_basic_product_path @product
    when 'description'
      redirect_to edit_description_product_path @product
    when 'location'
      redirect_to edit_location_product_path @product
    when 'photo'
      redirect_to edit_photo_product_path @product
    when 'price'
      redirect_to edit_price_product_path @product
    else
      redirect_to edit_basic_product_path @product
    end
    
  end

  def edit_basic
    @show_section = 'basic'
    render :layout => 'product_new', :template => 'products/edit'
  end

  def edit_description
    @show_section = 'description'
    render :layout => 'product_new', :template => 'products/edit'
  end

  def edit_location
    @show_section = 'location'
    render :layout => 'product_new', :template => 'products/edit'
  end

  def edit_photo
    @show_section = 'photo'
    render :layout => 'product_new', :template => 'products/edit'
  end

  def edit_price
    @show_section = 'price'
    render :layout => 'product_new', :template => 'products/edit'
  end

  # PATCH/PUT /products/1
  # PATCH/PUT /products/1.json
  def update
    respond_to do |format|
      if params[:product].present?
        unless @product.update(product_params)
          format.html { render :edit }
          format.json { render json: @product_attachment.errors, status: :unprocessable_entity }
        end
      end
      
      param_variants = params[:variant]
      if param_variants.present?
        param_variants.delete_if{|sa| !sa.stringify_keys['name'].present? }
        @product.variants.delete_all
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

      step_param = params["step-param"]
      case step_param
      when "basic"
        if @product.step == 'basic'
          @product.step = 'description'
          @product.save
        end
        format.html { redirect_to edit_description_product_path @product }
        format.json { render :show, status: :ok, location: @product_attachment }
      when "description"
        if @product.step == 'description'
          @product.step = 'location'
          @product.save
        end
        format.html { redirect_to edit_location_product_path @product }
        format.json { render :show, status: :ok, location: @product_attachment }
      when "location"
        if @product.step == 'location'
          @product.step = 'photo'
          @product.save
        end
        format.html { redirect_to edit_photo_product_path @product }
        format.json { render :show, status: :ok, location: @product_attachment }
      when "photo"
        if @product.step == 'photo'
          @product.step = 'price'
          @product.save
        end
        format.html { redirect_to edit_price_product_path @product }
        format.json { render :show, status: :ok, location: @product_attachment }
      when "price"
        if @product.step == 'price'
          @product.step = 'complete'
          @product.save
        end
        format.html { redirect_to products_path }
        format.json { render :show, status: :ok, location: @product_attachment }
      else
        format.html { redirect_to products_path }
        format.json { render :show, status: :ok, location: @product_attachment }
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
    
    @products = Product.where(:step => 5)

    if params[:city].present?
      # str_query += " or (lower(city) LIKE '%#{params[:city].downcase}%' or lower(country) like '%#{params[:city].downcase}%')"
      @products = @products.where("lower(city) LIKE ? or lower(country) like ?", "%#{params[:city].downcase}%", "%#{params[:city].downcase}%")
      @city = params[:city]
      # User.where(:user_type => 'broker').where.not("lower(email) LIKE ?", "%broker%").delete_all
    end

    @product_categories = ProductCategory.all
    category_names = @product_categories.select(:name).pluck(:name).map(&:downcase)
    if params[:search_free_text].present?
      # str_query += " and (lower(name) LIKE %#{params[:search_free_text].downcase}%)"
      if category_names.include? params[:search_free_text].downcase
        product_category = ProductCategory.where("lower(name) = ?", "#{params[:search_free_text].downcase}").first
        @products = @products.where(:product_category_id => product_category.id)
        @product_categories.each do |category|
          params["category_#{category.id}"] = "0"
        end
        params["category_#{product_category.id}"] = "1"
      else
        @products = @products.where("lower(name) LIKE ?", "%#{params[:search_free_text].downcase}%")
        @search_free_text = params[:search_free_text]
      end
    end

    @categories = {}
    str_query = 'product_category_id = -1'
    temp_index = 0
    ProductCategory.order('id').each do |category|
      if params["category_#{category.id}"] == "on"
        @categories["category_#{category.id}"] = "1"
      else
        @categories["category_#{category.id}"] = params["category_#{category.id}"]
      end
      if @categories["category_#{category.id}"].present? && @categories["category_#{category.id}"].to_i
        temp_index += 1
        str_query += " or product_category_id = #{category.id}"
      end
    end
    @products = @products.where(str_query)

    # set price range
    current_rate = session["currency-convert-#{session[:currency]}"].to_f
    gon.min_price = 0
    gon.max_price = current_rate * 1000

    # filter by price
    set_product_currency_attributes(@products)

    # binding.pry

    if params[:start_price].present?
      start_price = params[:start_price].to_f
      end_price = params[:end_price].to_f
      gon.start_price = start_price
      gon.end_price = end_price
      @products = @products.select{ |sa| sa.price_with_currency >= start_price && sa.price_with_currency <= end_price }

    end

    @total_count = @products.count
    # binding.pry
    if @products.class == Array
      @products = Kaminari.paginate_array(@products).page(params[:page]).per(8)
    else
      @products = @products.page(params[:page]).per(8)
    end
    
    params_clone = params.clone
    params_clone.delete("controller")
    params_clone.delete("action")
    gon.current_location = "/products/result?#{params.to_query}"

    set_product_attributs(@products)
    set_product_currency_attributes(@products)
    
    @current_currency = get_all_currency_symbols[session[:currency]]


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

    def set_product_widget
      set_product
      @categories = ProductCategory.all
    end

  	def product_params
      op = params.require(:product).permit(:name, :product_category_id, :payment_type, :location_id, 
        :country, :address, :apt, :city, :state, :zip, :price_cents, :currency, :description, 
        :highlight, :refundable, :refund_day, :refund_percent, :variants_attributes => [:id, :name, :price_cents])
      op[:price_cents] = op[:price_cents].to_i * 100
      op
    end

    def set_product_attributs(products)
      products.each do |product|
        if product.product_attachments.present? && product.product_attachments.count > 0
          product.product_overview_url = product.product_attachments[0].attachment.medium.url
        end
        product.user_avatar_url = product.user.get_avatar_url
      end
    end

    def set_product_currency_attributes(products)
      products.each do |product|
        if product.currency != session[:currency]
          rate = session["currency-convert-#{session[:currency]}"].to_f / session["currency-convert-#{product.currency}"].to_f
        else
          rate = 1.0
        end
        product.price_with_currency = (product.price_cents * rate / 100).round(2)
        product.current_currency = session[:currency]
      end
    end

end
