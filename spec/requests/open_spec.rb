require 'rails_helper'

describe 'slash_commands/incident open' do
  include SlackHelper

  before do
    disable_slack_signature_checks!
  end

  context 'with a command' do
    let(:payload) do
      default_slash_command_payload.merge({
        command: '/incident',
        text: 'open',
        trigger_id: 'test-trigger-id',
      })
    end

    it 'successfully processes the request' do
      modal_json = JSON.parse(Rails.root.join('lib/view_payloads/incident.json').read)

      view_payload = modal_json.merge(
        {
          'private_metadata' => payload[:channel_id],
        },
      )

      open_view_stub = stub_slack_open_view(trigger_id: 'test-trigger-id', view_payload: JSON.generate(view_payload))

      post '/api/slack/command', params: payload

      expect(open_view_stub).to have_been_requested
      expect(response.status).to eq 204
    end
  end
end
