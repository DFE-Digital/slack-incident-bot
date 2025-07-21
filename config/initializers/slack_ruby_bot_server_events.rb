SlackRubyBotServer::Events.configure do |config|
  config.signing_secret ||= ENV.fetch('SLACK_SIGNING_SECRET', nil)
  config.signature_expires_in ||= 300
end
