ENV['RAILS_ENV'] ||= 'test'
require File.expand_path(File.join(Rails.root,'/config/environment'), __FILE__)

require 'active_support/test_case'
require 'action_controller/test_case'
require 'action_dispatch/testing/integration'
require 'rails/generators/test_case'

# Config Rails backtrace in tests.
require 'rails/backtrace_cleaner'
if ENV["BACKTRACE"].nil?
	MiniTest.backtrace_filter = Rails.backtrace_cleaner
end

if defined?(ActiveRecord::Base)
	class ActiveSupport::TestCase
		include ActiveRecord::TestFixtures
		self.fixture_path = "#{Rails.root}/test/fixtures/"
	end

	ActionDispatch::IntegrationTest.fixture_path = ActiveSupport::TestCase.fixture_path

	def create_fixtures(*fixture_set_names, &block)
		FixtureSet.create_fixtures(ActiveSupport::TestCase.fixture_path, fixture_set_names, {}, &block)
	end
end

class ActionController::TestCase
	setup do
		@routes = Rails.application.routes
	end
end

class ActionDispatch::IntegrationTest
	setup do
		@routes = Rails.application.routes
	end
end

class ActiveSupport::TestCase
#  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all#

#  # Add more helper methods to be used by all tests here...
end
