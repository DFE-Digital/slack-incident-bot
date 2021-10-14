# This file is used by Rack-based servers to start the application.
ENV['RACK_ENV'] ||= 'development'

require_relative 'config/environment'

# Requires Slack Bot Actions

require_relative 'bot/slash_commands'
require_relative 'bot/actions'
require 'yaml'
require 'erb'

ActiveRecord::Base.establish_connection(
  YAML.safe_load(
    ERB.new(
      File.read('config/postgresql.yml'),
    ).result, [], [], true
  )[ENV['RACK_ENV']],
)

run Rails.application
