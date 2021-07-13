SlackRubyBotServer::Events.configure do |config|
  config.on :action, 'view_submission' do |action|
    action.logger.info "Received #{action[:payload][:type]}."

    begin
      if action[:payload][:view][:app_id] == ENV['SLACK_APP_ID']
        t1 = Time.now
        SlackIncidentActions.new.open_incident(action)
        t2 = Time.now
        puts t2 - t1
      end
    rescue Slack::Web::Api::Errors::NameTaken => e
      slack_client = Slack::Web::Client.new(token: ENV['SLACK_TOKEN'])
      slack_client.chat_postEphemeral(channel: action[:payload][:user][:id], user: action[:payload][:user][:id],
                                      text: 'That incident channel name has already been taken. Please try another.')
    rescue Slack::Web::Api::Errors::CantInviteSelf => e
      slack_client = Slack::Web::Client.new(token: ENV['SLACK_TOKEN'])
      slack_client.chat_postEphemeral(channel: action[:payload][:user][:id], user: action[:payload][:user][:id],
                                      text: 'You can’t invite the bot to the channel. You’ll need to manually add the leads now.')
    end
    nil
  end
end
