# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_hazard_session',
  :secret      => 'e979ae072e551e26417831767d0a5644a938b1abb0cf629e2f668c2fe85eb742d33f0692c2c5b2ae44d8889c89a66ae4eac05af34a3ebe8261642d5a10e105ab'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
