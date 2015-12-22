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
end