SlackRubyBotServer::Events.configure do |config|
  config.on :action, 'view_submission' do |action|
    action.logger.info "Received #{action[:payload][:type]}."

    begin
      if action[:payload][:view][:app_id] == ENV['SLACK_APP_ID']
        if action[:payload][:view][:callback_id] == 'incident-update-modal-identifier'
          channel_id = Rails.cache.read('channel')
          SlackIncidentActions.new.update_incident(action, channel_id)
        else
          SlackIncidentActions.new.open_incident(action)
        end
      end
    rescue Slack::Web::Api::Errors::NameTaken
      SlackMethods.post_a_message_to_user(
        user_id,
        user_id,
        'That incident channel name has already been taken. Please try another.',
      )
    rescue Slack::Web::Api::Errors::CantInviteSelf
      SlackMethods.post_a_message_to_user(
        user_id,
        user_id,
        'You can’t invite the bot to the channel. You’ll need to manually add the leads now.',
      )
    rescue Slack::Web::Api::Errors::TooLong
      SlackMethods.post_a_message_to_user(
        user_id,
        user_id,
        'Your incident description was too long. You’ll need to manually add it now.',
      )
    end
    nil
  end
end
