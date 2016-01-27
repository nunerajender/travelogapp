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

  # PUT /resource/invitation
  def update
    raw_invitation_token = update_resource_params[:invitation_token]
    self.resource = accept_resource
    invitation_accepted = resource.errors.empty?

    yield resource if block_given?

    if invitation_accepted
      if Devise.allow_insecure_sign_in_after_accept
        # credit logic
        resource.reward_credit = 5
        inviter = resource.invited_by
        inviter.reward_credit += 5
        inviter.save
        flash_message = resource.active_for_authentication? ? :updated : :updated_not_active
        set_flash_message :notice, flash_message if is_flashing_format?
        sign_in(resource_name, resource)
        respond_with resource, :location => after_accept_path_for(resource)
      else
        set_flash_message :notice, :updated_not_active if is_flashing_format?
        respond_with resource, :location => new_session_path(resource_name)
      end
    else
      resource.invitation_token = raw_invitation_token
      respond_with_navigational(resource){ render :edit }
    end
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