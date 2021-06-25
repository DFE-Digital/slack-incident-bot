$LOAD_PATH.unshift File.expand_path('..', __dir__)

ENV['RACK_ENV'] = 'test'

require 'active_support'
Bundler.require

require 'slack-ruby-bot-server/rspec'
require 'database_cleaner'

db_config = YAML.safe_load(File.read(File.expand_path('../config/postgresql.yml', __dir__)), [], [],
                           true)[ENV['RACK_ENV']]
ActiveRecord::Tasks::DatabaseTasks.create(db_config)
ActiveRecord::Base.establish_connection(db_config)

RSpec.configure do |config|
  config.before :suite do
    DatabaseCleaner.strategy = :deletion
    DatabaseCleaner.clean
  end

  config.around :each do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end
