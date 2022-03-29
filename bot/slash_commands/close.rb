SlackRubyBotServer::Events.configure do |config|
  config.on :command, '/closeincident' do |command|
    channel_name = command[:channel_name]
    channel_id = command[:channel_id]

    begin
      if channel_name.include? 'incident'
        message = SlackMethods.post_a_message(channel_id, '<!here> This incident has now closed.')
        channel_calling_incident = Rails.cache.read('channel_calling_incident')

        SlackMethods.pin_a_message(channel_id, message[:ts])

        SlackMethods.post_a_message(channel_calling_incident, ":white_check_mark: <!channel> The incident in <##{channel_id}> has now closed.")

        { text: 'You’ve closed the incident.' }
      else
        { text: 'This is not an incident channel.' }
      end
    rescue Slack::Web::Api::Errors::NotInChannel
      { text: 'This is not an incident channel.' }
    end
  end
end
