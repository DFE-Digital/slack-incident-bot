SlackRubyBotServer::Events.configure do |config|
  config.on :command, '/ping' do |_command|
    Rails.logger.info 'Received a ping, responding with pong.'
    { text: 'pong' }
  end
end
