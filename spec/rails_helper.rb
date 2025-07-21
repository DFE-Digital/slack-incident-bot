require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
# Set required environment variables for testing
ENV['SLACK_OAUTH_SCOPE'] ||= 'bot,commands'

require File.expand_path('../config/environment', __dir__)
# Prevent database truncation if the environment is production
abort('The Rails environment is running in production mode!') if Rails.env.production?
require 'rspec/rails'

Rails.root.glob('bot/slash_commands/**/*.rb').each { |f| require f }
Rails.root.glob('bot/actions/**/*.rb').each { |f| require f }

Rails.root.glob('spec/support/**/*.rb').each { |f| require f }

require 'webmock/rspec'

RSpec.configure(&:infer_spec_type_from_file_location!)
