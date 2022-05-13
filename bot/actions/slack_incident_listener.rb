SlackRubyBotServer::Events.configure do |config|
  config.on :action, 'view_submission' do |action|
    action.logger.info "Received #{action[:payload][:type]}."

    begin
      if action[:payload][:view][:app_id] == ENV['SLACK_APP_ID']
        if action[:payload][:view][:callback_id] == 'incident-update-modal-identifier'
          channel_id = action[:payload][:view][:private_metadata]
          SlackIncidentActions.new.update_incident(action, channel_id)
        else
          channel_calling_incident = action[:payload][:view][:private_metadata]
          SlackIncidentActions.new.open_incident(action, channel_calling_incident)
        end
      end
    rescue Slack::Web::Api::Errors::NameTaken
      SlackMethods.post_a_message_to_user(
        action[:payload][:user][:id],
        action[:payload][:user][:id],
        'That incident channel name has already been taken. Please try another.',
      )
    rescue Slack::Web::Api::Errors::CantInviteSelf
      SlackMethods.post_a_message_to_user(
        action[:payload][:user][:id],
        action[:payload][:user][:id],
        'You can’t invite the bot to the channel. You’ll need to manually add the leads now.',
      )
    rescue Slack::Web::Api::Errors::TooLong
      SlackMethods.post_a_message_to_user(
        action[:payload][:user][:id],
        action[:payload][:user][:id],
        'Your incident description was too long. You’ll need to manually add it now.',
      )
    rescue Slack::Web::Api::Errors::NotInChannel
      SlackMethods.post_a_message_to_user(
        action[:payload][:user][:id],
        action[:payload][:user][:id],
        'The bot is not in this channel. You’ll need to manually alert it now.',
      )
    end
    nil
  end
end
