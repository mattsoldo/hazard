# Settings specified here will take precedence over those in config/environment.rb

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = false

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_view.debug_rjs                         = true
config.action_controller.perform_caching             = false

# Don't care if the mailer can't send
config.action_mailer.raise_delivery_errors = false
config.gem 'annotate', :lib => 'annotate'
config.gem 'bullet'
config.gem 'inaction_mailer', :lib => 'inaction_mailer/force_load'
config.middleware.use "Rack::Bug"

config.after_initialize do
  Bullet.enable = false           # flip to true to enable bullet
  Bullet.alert = true             # javascript alert in browser
  Bullet.bullet_logger = true     # log to separate bullet.log
  Bullet.console = true           # log to browser console (Webkit or Firebug)
  Bullet.growl = false            # log to Growl
  Bullet.rails_logger = false     # log to current Rails log
  Bullet.disable_browser_cache = true
end
