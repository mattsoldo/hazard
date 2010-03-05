# NOTE: Regardless of these settings, admin_data is always usable in development (localhost:3000/admin_data)
AdminDataConfig.set = {
  :is_allowed_to_view => lambda {|controller| controller.send('view_admin_data?') },
  :is_allowed_to_update => lambda {|controller| controller.send('edit_admin_data?') },
  :feed_authentication_user_id => "my_user",
  :feed_authentication_password => "my_password" 
}

# Make admin_data play nice with XSS protection
class AdminData::Util

  class << self
    alias_method :unsafe_javascript_include_tag, :javascript_include_tag
    alias_method :unsafe_stylesheet_link_tag, :stylesheet_link_tag
  end
  
  def self.safe_javascript_include_tag(*args)
    self.unsafe_javascript_include_tag(*args).html_safe!
  end

  def self.safe_stylesheet_link_tag(*args)
    self.unsafe_stylesheet_link_tag(*args).html_safe!
  end

  class << self
    alias_method :javascript_include_tag, :safe_javascript_include_tag
    alias_method :stylesheet_link_tag, :safe_stylesheet_link_tag
  end

end
