# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
ENV['Host_With_Protocol'] = 'http://localhost'
require File.expand_path("../../config/environment", __FILE__)

require 'rspec/rails'
#require 'rspec/autorun'    # For zeus: https://github.com/burke/zeus/issues/280
require 'capybara/rails'
require 'sidekiq/testing'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

# TODO: remove
# This leads to unpredictable failures in tests, due to race conditions
#
# If you are using Capybara for javascript tests and Active Record, add the lines below to your spec_ helper and be sure you are running with transactional fixtures
# equals to true http://blog.plataformatec.com.br/tag/capybara/
# class ActiveRecord::Base
#  mattr_accessor :shared_connection
#  @@shared_connection = nil
#
#  def self.connection
#    @@shared_connection || retrieve_connection
#  end
# end

# Forces all threads to share the same connection. This works on
# Capybara because it starts the web server in a thread.
# ActiveRecord::Base.shared_connection = ActiveRecord::Base.connection

RSpec.configure do |config|

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  # False because we are adding elaborate config in spec/support/database_cleaner.rb
  config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"

  #  config.before(:each) do
  #    ActiveRecord::Base.connection.increment_open_transactions
  #    ActiveRecord::Base.connection.begin_db_transaction
  #  end

  #  config.after(:each) do
  #    ActiveRecord::Base.connection.rollback_db_transaction
  #    ActiveRecord::Base.connection.decrement_open_transactions
  #  end

  # To avoid repeating FactoryBot everywhere
  config.include FactoryBot::Syntax::Methods

  #to load the new factories created
  config.before(:all) do
    FactoryBot.reload
  end

  #Capybara.default_driver = :selenium
  ## Javascript driver
  Capybara.javascript_driver = :webkit
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

DatabaseCleaner.strategy = :truncation

__END__

#require 'capybara/dsl'
#include Capybara::DSL
#Capybara.app = Rack::File.new File.dirname __FILE__
#require './spec/spec_helper.rb'
#visit '/foo.html'