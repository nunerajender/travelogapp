module ProductsHelper
	def get_product_category_name(category_id)
    category = ProductCategory.find(category_id)
    category.name if category.present?
  end

  def get_country_list
  	ret = [{:country => 'Malaysia'}]
  end

  def get_currency_list
  	ret = [{:currency => 'USD'}, {:currency => 'MYR'}, {:currency => 'SGD'}, {:currency => 'THB'}, 
  				{:currency => 'PHO'}, {:currency => 'TWD'}]
  end
end
