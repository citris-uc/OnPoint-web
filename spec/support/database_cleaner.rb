require 'database_cleaner'

RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
    # load Rails.root.join("db", "seeds.rb")
  end

  config.around(:each) do |example|
    DatabaseCleaner.strategy = :transaction

    # NOTE: If this starts giving you problems, read this comment thread to see if
    # there are any issues:
    # https://github.com/DatabaseCleaner/database_cleaner/issues/273
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end
