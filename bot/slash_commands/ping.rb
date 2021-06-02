SlackRubyBotServer::Events.configure do |config|
  config.on :command, '/ping' do |command|
    p command
    command.logger.info 'Received a ping, responding with pong.'
    { text: 'pong' }
  end
end
