class InvitationsController < Devise::InvitationsController


	# GET /resource/invitation/new
  def new
    self.resource = resource_class.new
    render :layout => 'product', :template => 'devise/invitations/new'
    # render 'new'
  end

	def create
		session[:root_domain] = root_url
		self.resource = invite_resource
    resource_invited = resource.errors.empty?

    yield resource if block_given?

    if resource_invited
      if is_flashing_format? && self.resource.invitation_sent_at
        set_flash_message :notice, :send_instructions, :email => self.resource.email
      end
      accept_link = accept_invitation_url(resource, :invitation_token => resource.invitation_token)

      respond_with resource, :location => after_invite_path_for(current_inviter)
    else
      respond_with_navigational(resource) { render :new }
    end
  end

  # GET /resource/invitation/accept?invitation_token=abcdef
  def edit
  	set_minimum_password_length if respond_to? :set_minimum_password_length
    resource.invitation_token = params[:invitation_token]
    render :edit
  end

  private

  # this is called when creating invitation
  # should return an instance of resource class
  def invite_resource
    ## skip sending emails on invite
    super do |u|
      # u.skip_invitation = true
    end
  end

end