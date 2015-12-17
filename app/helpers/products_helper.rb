module ProductsHelper
	def get_product_category_name(category_id)
    category = ProductCategory.find(category_id)
    category.name if category.present?
  end
end
