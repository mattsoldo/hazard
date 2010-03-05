require File.join(File.dirname(__FILE__), '..', 'test_helper')

class NewUserCanRegisterTest < ActionController::IntegrationTest
  context 'a site visitor' do
    
    should 'be able to create a new account' do
      visit root_path
      click_link 'Register'
      
      assert_equal new_account_path, path
      assert_contain 'Register'
      
      fill_in 'First Name', :with => "Francis"
      fill_in 'Last Name', :with => "Ferdinand"
      fill_in 'Login', :with => 'francis'
      fill_in 'Email', :with => 'francis@example.com'
fill_in 'Password', :with => 'spambot'
fill_in 'Password Confirmation', :with => 'spambot'

      click_button 'Register'
      
      assert_equal root_path, path
      assert_contain I18n.t("flash.accounts.create.notice")
    end
  end
end
