# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  helper :all # include all helpers, all the time
  include SimpleCaptcha::ControllerHelpers
  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '844b34c72fef7e714a3916401d689bc6'
  before_filter :set_user_language
  
  

  protected 

  def set_user_language
    I18n.locale =  current_subdomain||'en'
  end


  
end
