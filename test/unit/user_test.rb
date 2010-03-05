require 'test_helper'

class UserTest < ActiveSupport::TestCase

  context "using authlogic" do
    setup do
      activate_authlogic
    end
  
    should_be_authentic

    context "#display_name" do
      should "combine first and last name" do
        @user = User.generate(:first_name => "Rocky", :last_name => "Squirrel")
        assert_equal "Rocky Squirrel", @user.display_name
      end

      should "handle first name only" do
        @user = User.generate(:first_name => "Rocky", :last_name => "")
        assert_equal "Rocky", @user.display_name
      end

      should "handle last name only" do
        @user = User.generate(:first_name => "", :last_name => "Squirrel")
        assert_equal "Squirrel", @user.display_name
      end
    end
  
    context "serialize roles" do
      setup do
        @user = User.generate
      end
    
      should "default to an empty array" do
        assert_equal [], @user.roles
      end
    
      should "allow saving and retrieving roles array" do
        @user.roles = ["soldier", "sailor", "spy"]
        @user.save
        user_id = @user.id
        user2 = User.find(user_id)
        assert_equal ["soldier", "sailor", "spy"], user2.roles
      end
    
      should "not allow non-array data" do
        assert_raise ActiveRecord::SerializationTypeMismatch do
          @user.roles = "snakeskin shoes"
          @user.save
        end
      end
    end
  
    should_callback :make_default_roles, :before_validation_on_create
    should_callback :send_welcome_email, :after_create
    
    should_allow_mass_assignment_of :login, :password, :password_confirmation, :first_name, :last_name, :email, :strict => true
  
    context "#deliver_password_reset_instructions!" do
      setup do
        @user = User.generate!
        Notifier.stubs(:password_reset_instructions).returns(nil)
      end
    
      should "reset the perishable token" do
        @user.expects(:reset_perishable_token!)
        @user.deliver_password_reset_instructions!
      end
    
      should "send the reset mail" do
        Notifier.expects(:deliver_password_reset_instructions).with(@user)
        @user.deliver_password_reset_instructions!
      end
    end
  
    
    context "#admin?" do
      setup do
        @user = User.generate
      end
    
      should "return true if the user has the admin role" do
        @user.add_role("admin")
        assert @user.admin?
      end
    
      should "return false if the user does not have the admin role" do
        @user.clear_roles
        assert !@user.admin?
      end
    end
  
    context "#has_role?" do
      setup do
        @user = User.generate
      end
    
      should "return true if the user has the specified role" do
        @user.add_role("saint")
        assert @user.has_role?("saint")
      end
    
      should "return false if the user does not have the specified role" do
        @user.clear_roles
        assert !@user.has_role?("saint")
      end
    end

    context "#has_any_role?" do
      setup do
        @user = User.generate
      end
      
      should "return true if the user has the first specified role" do
        @user.add_role("saint")
        assert @user.has_any_role?("saint", "sinner")
      end
      
      should "return true if the user has any other role in the array" do
        @user.add_role("sinner")
        assert @user.has_any_role?("saint", "sinner")
      end
      
      should "return false if the user does not have any of the specified roles" do
        @user.clear_roles
        assert !@user.has_any_role?("saint", "sinner")
      end

      should "return false if the user has only roles not in the list" do
        @user.add_role("president")
        assert !@user.has_any_role?("saint", "sinner")
      end
    end
      
    context "#add_role" do
      should "add the specified role" do
        @user = User.generate
        @user.add_role("wombat")
        assert @user.roles.include?("wombat")
      end    
      
      should "not add duplicate roles" do
        @user = User.generate
        @user.add_role("wombat")
        @user.add_role("wombat")
        assert_equal ["wombat"], @user.roles
      end
    end
  
    context "#remove_role" do
      should "remove the specified role" do
        @user = User.generate
        @user.add_role("omnivore")
        @user.remove_role("omnivore")
        assert !@user.roles.include?("omnivore")
      end
    end
  
    context "#clear_roles" do
      should "have no roles after clearing" do
        @user = User.generate
        @user.add_role("cat")
        @user.add_role("dog")
        @user.add_role("goldfish")
        @user.clear_roles
        assert_equal [], @user.roles
      end
    end
  
    context "#has_permission?" do          
      setup do
        @regular_user = User.generate
        @admin_user = User.generate
        @admin_user.add_role("admin")
      end
        
      context ":view_admin_data" do
        should "be true for an admin user" do
          assert @admin_user.has_permission?(:view_admin_data)
        end
        
        should "be false for a regular user" do
          assert !@regular_user.has_permission?(:view_admin_data)
        end
      end
      
      context ":edit_admin_data" do
        should "be true for an admin user" do
          assert @admin_user.has_permission?(:edit_admin_data) 
        end
        
        should "be false for a regular user" do
          assert !@regular_user.has_permission?(:edit_admin_data) 
        end
      end
    end
    
    context "#kaboom!" do
      should "blow up predictably" do
        assert_raise NameError do
          @user = User.generate!
          @user.kaboom!
        end
      end
    end
  end 
end
