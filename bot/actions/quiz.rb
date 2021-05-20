SlackRubyBotServer::Events.configure do |config|
  config.on :action, 'block_actions' do |action|
    payload = action[:payload]
    action_id = payload["actions"][0]["action_id"]
    channel_id = payload["channel"]["id"]
    team_id = payload["team"]["id"]
    action.logger.info "Action #{action_id} has been processed in channel #{channel_id}"
    team = Team.find_by(team_id: team_id)
    slack_client = Slack::Web::Client.new(token: team.token)
    if action_id == 'reply_yes'
      slack_client.chat_postMessage(channel: channel_id, text: "Great! I also think so! :thumbsup:")
    elsif action_id == 'reply_no'
      slack_client.chat_postMessage(channel: channel_id, text: "Oops! Try to google it... :thumbsdown:")
    end
    # Do not send text message any more
    nil
  end
end
