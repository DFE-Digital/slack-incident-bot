SlackRubyBotServer::Events.configure do |config|
  config.on :command, '/closeincident' do |command|
    channel_name = command[:channel_name]
    channel_id = command[:channel_id]

    begin
      if channel_name.include? 'incident'
        message = SlackMethods.post_a_message(channel_id, '<!here> This incident has now closed.')
        channel_calling_incident = Rails.cache.read('channel_calling_incident')

        keys_to_extract = %w[text user ts thread_ts]

        conversation = SlackMethods.get_chat(channel_id)['messages']

        message_hash = conversation.map { |m| m.select { |k, _| keys_to_extract.include? k } }

        threaded_messages = message_hash.select { |hash| hash['thread_ts'] }

        export = message_hash

        if threaded_messages.any?

          replies = threaded_messages.map { |thread| SlackMethods.get_replies(channel_id, thread['ts']) }

          replies = replies.map do |hash|
            hash['messages']
          end

          reply_hash = replies.map { |reply| reply.select { |k, _| keys_to_extract.include? k } }

          export += reply_hash

        end

        SlackMethods.post_file(channel_id, export.to_json, 'incident_export', 'text', 'test')

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
