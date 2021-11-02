$LOAD_PATH.unshift File.expand_path('..', __dir__)

ENV['RACK_ENV'] = 'test'

require 'active_support'
Bundler.require

require 'vcr'
require 'webmock/rspec'

VCR.configure do |config|
  config.cassette_library_dir = 'spec/fixtures/slack'
  config.hook_into :webmock
  # config.default_cassette_options = { record: :new_episodes }
  config.configure_rspec_metadata!
  config.before_record do |i|
    i.request.body.gsub!(ENV['SLACK_TOKEN'], 'token') if ENV.key?('SLACK_TOKEN')
    i.response.body.force_encoding('UTF-8')
  end
end
