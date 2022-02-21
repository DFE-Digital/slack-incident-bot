require 'rails_helper'

describe 'slash_commands/incident' do
  include SlackHelper

  before do
    disable_slack_signature_checks!
  end

  context 'with a command' do
    let(:payload) do
      default_slash_command_payload.merge({
        command: '/incident',
        trigger_id: 'test-trigger-id',
      })
    end

    it 'successfully processes the request' do
      view_payload = JSON.generate(
        JSON.parse(
          File.read(Rails.root.join('lib/view_payloads/incident.json')),
        )
      )

      stub_slack_open_view(trigger_id: 'test-trigger-id', view_payload: view_payload)
      post '/api/slack/command', params: payload

      expect(response.status).to eq 204
    end
  end
end
