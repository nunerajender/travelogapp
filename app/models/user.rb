class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable, :omniauth_providers => [:facebook]

  has_many :products
  has_one :profile
  has_one :store_setting
  after_create :send_welcome_message
  enum status: {
    normal: 0,
    merchant: 1
  }

  attr_accessor :avatar_url
  
  def self.from_omniauth(auth)
  	
	  	where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      
      auth.info.image = auth.info.image+"?type=large"
      logger.info "status=facebook image type Auth #{auth.info.image}"
	    user.email = auth.info.email
	    user.password = Devise.friendly_token[0,20]

      user.build_profile(first_name:auth.info.first_name,last_name:auth.info.last_name,avatar:auth.info.image)
	    #user.name = auth.info.name   # assuming the user model has a name
	    #user.image = auth.info.image # assuming the user model has an image
	  end
	end

  

	def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
        user.email = data["email"] if user.email.blank?
      end
    end
  end

  def get_avatar_url
    ret = ''
    if self.profile.present? && self.profile.user_avatar.present?
      ret = self.profile.user_avatar.avatar.thumb.url
    end
    if ret.blank? && self.provider == 'facebook'
      ret = self.profile.avatar
    end
    ret
  end
 

  private

  def send_welcome_message
    #UserMailer.welcome_message(self).deliver
    
  end


end
