class Notifier < ActionMailer::Base
  default_url_options[:host] = "example.com"
  
  def password_reset_instructions(user)
    setup(user)
    subject I18n.t("subject.password_reset_instructions")
    body :edit_password_reset_url => edit_password_reset_url(user.perishable_token)
  end

  def welcome_email(user)
    setup(user)
    subject I18n.t("subject.welcome")
    body :user => user
  end
  
  
private

  def setup(user)
    from "Lark Group <noreply@example.com>"
    sent_on Time.now
    recipients user.email
  end
  
end
