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
        if params[:variant].present? && params[:variant].count > 0
          params[:variant].each do |param_variant|
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
        if params[:variant].present? && params[:variant].count > 0
          base_price_cents = params[:variant][0][:price_cents].to_i * 100
          params[:variant].each do |param_variant|
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
    # @products = Product.where("name LIKE ? OR city LIKE ?", "%#{params[:name]}%", "%#{params[:city]}%")
    if params[:city].present?
      @products = Product.where("lower(city) LIKE ?", "%#{params[:city].downcase}%")
    end
    if params[:search_free_text].present?
      @products = @products.where("lower(name) LIKE ?", "%#{params[:search_free_text].downcase}%")
    end
    @products = Product.all if @products.blank?
    @products.each do |product|
      if product.product_attachments.present? && product.product_attachments.count > 0
        product.product_overview_url = product.product_attachments[0].attachment.medium.url
      end
      product.user_avatar_url = product.user.get_avatar_url
    end
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
      # op[:variants_attributes] = params[:variant]
      # binding.pry
      op
    end



end
