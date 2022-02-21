require 'rails_helper'

describe 'slash_command/update' do
  include SlackHelper

  before do
    disable_slack_signature_checks!
  end

  context 'with a valid update command' do
    let(:payload) do
      default_slash_command_payload.merge({
        command: '/update',
        channel_id: 'channel',
        channel_name: 'incident_channel_name',
        trigger_id: 'test-trigger-id',
      })
    end

    it 'returns incident updated confirmation' do
      view_payload = JSON.generate(
        JSON.parse(
          File.read(Rails.root.join('lib/view_payloads/update.json')),
        )
      )

      stub_slack_open_view(trigger_id: 'test-trigger-id', view_payload: view_payload)
      post '/api/slack/command', params: payload
      expect(JSON.parse(response.body)).to eq('text' => 'You’ve updated the incident.')
      expect(response.status).to eq 201
    end
  end

  context 'with an invalid update command' do
    let(:payload) do
      default_slash_command_payload.merge({
        command: '/update',
        channel_id: 'channel',
        channel_name: 'unrelated_channel_name',
        trigger_id: 'test-trigger-id',
      })
    end

    it 'returns the error message' do
      post '/api/slack/command', params: payload

      expect(response.status).to eq 201
      expect(JSON.parse(response.body)).to eq('text' => 'This is not an incident channel.')
    end
  end
end
