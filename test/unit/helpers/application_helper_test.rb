require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  
  context "#anonymous_only" do
    should "call the supplied block if the current user is anonymous" do
      self.stubs(:logged_in?).returns(false)
      assert_equal "result", anonymous_only {"result"}
    end

    should "not call the supplied block if the current user is logged in" do
      self.stubs(:logged_in?).returns(true)
      assert_nil anonymous_only {"result"}
    end
  end
  
  context "#authenticated_only" do
    should "call the supplied block if the current user is logged in" do
      self.stubs(:logged_in?).returns(true)
      assert_equal "result", authenticated_only {"result"}
    end

    should "not call the supplied block if the current user is anonymous" do
      self.stubs(:logged_in?).returns(false)
      assert_nil authenticated_only {"result"}
    end
  end
  
  context "#admin_only" do
    setup do
      @current_user = User.generate
    end
    
    should "call the supplied block if the current user is logged in and an admin" do
      @current_user.add_role("admin")
      self.stubs(:current_user).returns(@current_user)
      assert_equal "result", admin_only {"result"}
    end

    should "not call the supplied block if the current user is anonymous" do
      self.stubs(:current_user).returns(nil)
      assert_nil admin_only {"result"}
    end

    should "not call the supplied block if the current user is logged in but not an admin" do
      self.stubs(:current_user).returns(@current_user)
      assert_nil admin_only {"result"}
    end
  end
  
end
