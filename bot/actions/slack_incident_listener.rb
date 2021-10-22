SlackRubyBotServer::Events.configure do |config|
  config.on :action, 'view_submission' do |action|
    SlackActionHandler.new(action).call
  end
end
