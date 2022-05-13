module IncidentCommands
  class Open
    class << self
      def perform(command)
        incident_payload = modal_json.merge(
          {
            'private_metadata' => command[:channel_id],
          },
        )
        SlackMethods.open_the_modal(command[:trigger_id], incident_payload)
      end

      def modal_json
        JSON.parse(
          File.read(Rails.root.join('lib/view_payloads/incident.json')),
        )
      end
    end
  end
end
