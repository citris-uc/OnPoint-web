ENV['RAILS_ENV'] = 'test'

ActiveRecord::Migration.check_pending!

#------------------------------------------------------------------------------

require 'rspec/rails'
# require 'webmock/rspec'
require 'sidekiq/testing/inline'
require 'support/database_cleaner'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
# NOTE: We need to use the directory of the rails_helper.rb rather than the app
# directory of dummy.
# http://viget.com/extend/rails-engine-testing-with-rspec-capybara-and-factorygirl
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }
Dir["#{File.dirname(__FILE__)}/factories/*.rb"].each { |f| require f }

#------------------------------------------------------------------------------
# WebMock configuration
#-----------------------
# WebMock.disable_net_connect!(:allow_localhost => true)

#------------------------------------------------------------------------------
RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods

  # This option ensures that we fail fast. It mimicks the hooks.rb behavior for our Cucumber suite.
  config.fail_fast = false
  config.color     = true

  config.after(:each) do
    Warden.test_reset!
  end

  config.before(:suite) do
    Warden.test_mode!

    # Before starting the suite, wipe the DB clean, then seed it.
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, :after_commit => true) do
    DatabaseCleaner.strategy = :truncation, { :except => %w[assessments answer_choices questions assessment_sections assessments_questions] }
  end

  config.before(:each, :js => true) do
    DatabaseCleaner.strategy = :truncation, { :except => %w[assessments answer_choices questions assessment_sections assessments_questions] }
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end


  # Include utility methods into the test scope.
  config.include Devise::TestHelpers, :type => :controller

  # We're using DatabaseCleaner instead of this built-in functionality.
  config.use_transactional_fixtures = false

  # Infer the base class of anonymous controllers automatically.
  config.infer_base_class_for_anonymous_controllers = true

  # Run specs in random order to surface order dependencies.
  # To debug an order dependency, use the seed, printed after each run.
  #     --seed 1234
  config.order = "random"

  # rspec-rails 3 will no longer automatically infer an example group's spec type
  # from the file location. You can explicitly opt-in to the feature using this
  # config option.
  # To explicitly tag specs without using automatic inference, set the `:type`
  # metadata manually:
  #
  #     describe ThingsController, :type => :controller do
  #       # Equivalent to being in spec/controllers
  #     end
  config.infer_spec_type_from_file_location!
end
