require 'rails_helper'

describe 'slash_commands/ping' do
  include SlackHelper

  before do
    disable_slack_signature_checks!
  end

  context 'with a command' do
    let(:payload) do
      default_slash_command_payload.merge({
        command: '/ping',
      })
    end

    it 'returns pong' do
      post '/api/slack/command', params: payload
      expect(response.parsed_body).to eq('text' => 'pong')
      expect(response.status).to eq 201
    end
  end
end
