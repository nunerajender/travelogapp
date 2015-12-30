class StoreController < ApplicationController
	before_action :authenticate_user!
	before_action :check_merchant
	def layout_by_resource
    "product"
  end

  def index
  	@store = current_user.store_setting
  end

  private

  def check_merchant
  	unless current_user.is_merchant?
  		true
  	end
  end
end
