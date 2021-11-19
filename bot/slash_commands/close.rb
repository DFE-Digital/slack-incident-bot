SlackRubyBotServer::Events.configure do |config|
  config.on :command, '/closeincident' do |command|
    channel_name = command[:channel_name]
    channel_id = command[:channel_id]
    command.logger.info "Closing the incident in #{channel_name}."

    slack_client = Slack::Web::Client.new(token: ENV['SLACK_TOKEN'])

    begin
      if channel_name.include? 'incident'
        message = slack_client.chat_postMessage(channel: channel_id, text: '<!here> This incident has now closed.')
        slack_client.pins_add(channel: channel_id, timestamp: message[:ts])
        slack_client.chat_postMessage(channel: 'twd_git_bat', text: ":white_check_mark: <!channel> The incident in <##{channel_id}> has now closed.")
        slack_client.chat_postMessage(channel: 'twd_getintoteaching', text: ":white_check_mark: <!channel> The incident in <##{channel_id}> has now closed.")
        { text: 'You’ve closed the incident.' }
      else
        { text: 'This is not an incident channel.' }
      end
    rescue Slack::Web::Api::Errors::NotInChannel
      { text: 'This is not an incident channel.' }
    end
  end
end
