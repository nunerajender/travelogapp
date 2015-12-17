class ProductsController < ApplicationController

	def layout_by_resource
    "product"
  end

  def index
  	@products = Product.all
  end

  def new
  	@product = Product.new
  	@categories = ProductCategory.all
  end

  def create
  	@product = Product.new(product_params)
  	@product.payment_type = params[:product][:payment_type].to_i
  	respond_to do |format|
      if @product.save
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
  

  private
  	def set_product
      @product = Product.find(params[:id])
    end

  	def product_params
      params.require(:product).permit(:name, :product_category_id, {attachments: []})
    end

end
