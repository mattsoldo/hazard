ENV["RAILS_ENV"] = "test" if ENV["RAILS_ENV"].nil? || ENV["RAILS_ENV"] == ''
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'
require 'shoulda'
require 'mocha'
require 'authlogic/test_case'
require 'webrat'

Webrat.configure do |config|
  config.mode = :rails
  config.open_error_files = false
end

# show less output on test benchmarks
# use (0,0) to suppress benchmark output entirely
Test::Unit::UI::Console::TestRunner.set_test_benchmark_limits(1,5)

# skip after_create callback during testing
class User < ActiveRecord::Base; def send_welcome_email; end; end

class ActiveSupport::TestCase


  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false

  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  #fixtures :all

  # Add more helper methods to be used by all tests here...

  # Helper method_missing override to create nicely-named collections of factory objects
  # For example: generate_factory_collection_for_current_students(15)
  # or spawn_factory_collection_for_current_students(15) to get a collection of unsaved objects
  def method_missing(requested_method, *args)
    if requested_method.to_s =~ /\Agenerate_factory_collection_for_(\w+)\Z/
      __send__("create_factory_collection", $1, args[0], true)
    elsif requested_method.to_s =~ /\Aspawn_factory_collection_for_(\w+)\Z/
        __send__("create_factory_collection", $1, args[0], false)
    else
      # Otherwise handle normally #
      super
    end
  end

  # Create a collection of factory objects with option to save or build
  def create_factory_collection(factory_name, size = 5, save_to_database = false)
    returning collection = [] do
      size.times do
        collection << (save_to_database ? factory_name.classify.constantize.generate() : factory_name.classify.constantize.spawn())
      end
    end
  end

end

# Make authlogic available to all controller tests
class ActionController::TestCase
  setup :activate_authlogic
end

