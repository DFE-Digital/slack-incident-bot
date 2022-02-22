require 'rails_helper'

describe 'slash_commands/close' do
  include SlackHelper

  before do
    disable_slack_signature_checks!
    incident_started_in('twd_git_bat')
  end

  let(:payload) do
    default_slash_command_payload.merge({
      command: '/closeincident',
      channel_id: channel_id,
      channel_name: channel_id,
    })
  end

  context 'with a valid incident channel' do
    let(:channel_id) { 'incident_channel_id' }
    let(:channel_name) { 'incident_channel_name' }

    it 'returns incident closed confirmation' do
      stub_slack_message(channel: 'incident_channel_id', message: '<!here> This incident has now closed.')
      stub_slack_pin(channel: 'incident_channel_id')
      stub_slack_message(channel: 'twd_git_bat', message: ':white_check_mark: <!channel> The incident in <#incident_channel_id> has now closed.')

      post '/api/slack/command', params: payload

      expect(JSON.parse(response.body)).to eq('text' => 'You’ve closed the incident.')
      expect(response.status).to eq 201
    end
  end

  context 'with an invalid incident channel' do
    let(:channel_id) { 'some_other_channel_id' }
    let(:channel_name) { 'some_other_channel_name' }

    it 'returns an error message' do
      post '/api/slack/command', params: payload
      expect(response.status).to eq 201
      expect(JSON.parse(response.body)).to eq('text' => 'This is not an incident channel.')
    end
  end
end
