SlackRubyBotServer.configure do |config|
  config.view_paths << File.expand_path(File.join(__dir__, '../../public'))
  config.oauth_version = :v2
  config.oauth_scope = ENV.fetch('SLACK_OAUTH_SCOPE').split(/\s*,\s*/)
end
