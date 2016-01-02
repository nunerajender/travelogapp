class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  include ApplicationHelper  

  before_action :authenticate_user!
  before_action :init_action
  
  layout :layout_by_resource


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
    session[:currency] = 'USD' if session[:currency].blank?
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
  end
end
