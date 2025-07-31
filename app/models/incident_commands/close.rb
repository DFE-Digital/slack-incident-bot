module IncidentCommands
  class Close
    attr_reader :channel_calling_incident

    def self.perform(command)
      channel_name = command[:channel_name]
      channel_id = command[:channel_id]

      begin
        if channel_name.include? 'incident'
          message = SlackMethods.post_a_message(channel_id, '<!here> This incident has now closed.')
          SlackMethods.pin_a_message(channel_id, message[:ts])

          post_to_channel_calling_incident(name, channel_id)
        else
          SlackMethods.post_a_message_to_user(
            command[:user_id],
            command[:user_id],
            'This is not an incident channel.',
          )
        end
      rescue Slack::Web::Api::Errors::NotInChannel
        SlackMethods.post_a_message_to_user(
          command[:user_id],
          command[:user_id],
          'This is not an incident channel.',
        )
      end
    end

    private

    def self.post_to_channel_calling_incident(channel_name, channel_id)
      if (channel_calling_incident = Rails.cache.read(channel_name))
        SlackMethods.post_a_message(
          channel_calling_incident,
          ":white_check_mark: <!channel> The incident in <##{channel_id}> has now closed.",
        )
      end
    end
  end
end
