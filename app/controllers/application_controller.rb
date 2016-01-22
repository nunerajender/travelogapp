class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  include ApplicationHelper  

  before_action :authenticate_user!
  before_action :init_action
  
  layout :layout_by_resource
  skip_before_action :authenticate_user!, only: [:set_currency]

  def set_currency
    session[:currency] = params["footer-currency"]
    redirect_to params["current-url"]
    # render json: true.to_json
  end

  protected

  def layout_by_resource
    if devise_controller?
      "users"
    else
      "application"
    end
  end

  def init_action

    # setting current currency
    session[:currency] = 'MYR' if session[:currency].blank?
    gon.current_currency = session[:currency]
    gon.currency_symbols = get_all_currency_symbols

    # setting currency rates
    rates = {}
    bank = Money::Bank::GoogleCurrency.new
    default_currency = 'USD'
    get_all_currencies.each do |currency|
      if default_currency == currency
        rate = 1.0
        session["currency-convert-USD"] = "1.0"
      else
        if session["currency-convert-#{currency}"].blank?
          rate = bank.get_rate(default_currency, currency)
          session["currency-convert-#{currency}"] = rate.to_s
        else
          rate = session["currency-convert-#{currency}"].to_f
        end
      end
      rates[currency] = rate
    end
    
    gon.currency_rates = rates
    gon.is_display_currency_exchange = true
  end

  def set_product_attributs(products)
    products.each do |product|
      if product.product_attachments.present? && product.product_attachments.count > 0
        product.product_overview_url = product.product_attachments[0].attachment.medium.url
      end
      product.user_avatar_url = product.user.get_avatar_url

      store_setting = product.user.store_setting
      if store_setting.present? && store_setting.store_image.present?
        # product.store_logo_url = product.user.store_setting.store_image.store_img.small
        product.store_logo_url = '/assets/default-avatar.png'
      else
        product.store_logo_url = '/assets/default-avatar.png'
      end

      # review the mark
      total_review = 0
      review_count = product.product_reviews.count
      if review_count > 0
        product.product_reviews.each do |review|
          total_review += review.rating_stars
        end
        product.review_mark = (total_review / review_count).round
      else
        product.review_mark = 0
      end
    end
  end

end
