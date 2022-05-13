module IncidentCommands
  class Update
    class << self
      def perform(command)
        channel_name = command[:channel_name]

        begin
          if channel_name.include? 'incident'
            update_payload = modal_json.merge(
              {
                'private_metadata' => command[:channel_id],
              },
            )
            SlackMethods.open_the_modal(command[:trigger_id], update_payload)
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
        rescue Slack::Web::Api::Errors::CantInvite
          SlackMethods.post_a_message_to_user(
            command[:user_id],
            command[:user_id],
            'Cant invite this user',
          )
        rescue Slack::Web::Api::Errors::NoUser
          SlackMethods.post_a_message_to_user(
            command[:user_id],
            command[:user_id],
            'No user',
          )
        end
      end

      def modal_json
        JSON.parse(
          File.read(Rails.root.join('lib/view_payloads/update.json')),
        )
      end
    end
  end
end
