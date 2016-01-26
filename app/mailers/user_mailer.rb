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

  def invite_message(invitee, accept_link)
    @invitee = invitee
    @inviter_name = @invitee.invited_by.full_name
    @accept_link = accept_link
    mail(:to => @invitee.email, :subject => "#{@inviter_name} invited you to Travelog")
  end
end