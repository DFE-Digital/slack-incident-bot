require 'rails_helper'

describe 'slash_command/incident update' do
  include SlackHelper

  before do
    disable_slack_signature_checks!
  end

  context 'with a valid update command' do
    let(:payload) do
      default_slash_command_payload.merge({
        command: '/incident',
        text: 'update',
        channel_id: 'channel',
        channel_name: 'incident_channel_name',
        trigger_id: 'test-trigger-id',
      })
    end

    it 'returns incident updated confirmation' do
      modal_json = JSON.parse(Rails.root.join('lib/view_payloads/update.json').read)

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

  context 'with an invalid update command' do
    let(:payload) do
      default_slash_command_payload.merge({
        command: '/incident',
        text: 'update',
        channel_id: 'channel',
        channel_name: 'unrelated_channel_name',
        trigger_id: 'test-trigger-id',
      })
    end

    it 'returns the error message' do
      error_message = stub_slack_ephemeral_error_message(channel: 'user_id', message: 'This is not an incident channel.')

      post '/api/slack/command', params: payload

      expect(response.status).to eq 204
      expect(error_message).to have_been_requested
    end
  end
end
