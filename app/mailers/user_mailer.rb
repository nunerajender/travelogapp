class UserMailer < ActionMailer::Base
  default from: "Travelog <no-reply@travelog.com>"
  
  def welcome_message(user)
  	logger.info "{event=registration status=successful user=#{user.email}}"
  	@user = user
  	mail(:to => user.email, :subject => "Welcome to Travelog")
  end

  def welcome_merchant(user,store)
  	logger.info "{event=registration_store status=successful store=#{store.name}}"
  end

  def write_review(from_user, product, message)
  	@from_user = from_user
  	@merchant = product.user
  	@message = message
  	@product_name = product.name
  	mail(:to => @merchant.email, :subject => "Review message on Travelog")
  end
end