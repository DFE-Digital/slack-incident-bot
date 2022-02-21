require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)
# Prevent database truncation if the environment is production
abort('The Rails environment is running in production mode!') if Rails.env.production?
require 'rspec/rails'

Dir[Rails.root.join('bot', 'slash_commands', '**', '*.rb')].sort.each { |f| require f }
Dir[Rails.root.join('bot', 'actions', '**', '*.rb')].sort.each { |f| require f }

Dir[Rails.root.join('spec/support/**/*.rb')].sort.each { |f| require f }

require 'webmock/rspec'

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!
end
