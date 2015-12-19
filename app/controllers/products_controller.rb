class ProductsController < ApplicationController
  before_action :set_product, only: [:show, :edit, :update, :destroy]

	def layout_by_resource
    "product"
  end

  def index
  	@products = Product.all
    @product_attachments = ProductAttachment.all
  end

  def new
  	@product = Product.new
  	@categories = ProductCategory.all
    @product_attachment = @product.product_attachments.build
    @product_attachments = ProductAttachment.all
  end

  def create
  	@product = Product.new(product_params)
  	respond_to do |format|
      if @product.save
        params[:product_attachment]['id'].each do |a|
          product_attachment = ProductAttachment.find(a)
          if product_attachment.present?
            product_attachment.product = @product
            product_attachment.save
          end
        end

        # format.html { redirect_to @product, notice: 'product was successfully created.' }
        format.html { redirect_to products_path, notice: 'Product was successfully created.' }
        format.json { render :show, status: :created, location: @product }
      else
        # format.html { render :new }
        format.html { redirect_to products_path }
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
        params[:product_attachment]['id'].each do |a|
          product_attachment = ProductAttachment.find(a)
          if product_attachment.present?
            product_attachment.product = @product
            product_attachment.save
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
      params.require(:product).permit(:name, :product_category_id, :payment_type)
    end

end
