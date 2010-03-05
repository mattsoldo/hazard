if Rails.env.production?
  ActionMailer::Base.smtp_settings = {
    :address => "111.111.111.111",
    :port => 25,
    :domain => "example.com",
    :authentication => :login,
    :user_name => "mikeg1@example.com",
    :password => "password"
  }
elsif Rails.env.staging?
  ActionMailer::Base.smtp_settings = {
    :address => "111.111.111.111",
    :port => 25,
    :domain => "example.com",
    :authentication => :login,
    :user_name => "mikeg1@example.com",
    :password => "password"
  }

end

# base64 encodings - useful for manual SMTP testing:
# username => bWlrZWcxQGV4YW1wbGUuY29t

# password => cGFzc3dvcmQ=
