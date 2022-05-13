require 'rails_helper'

describe 'slash_commands/incident close' do
  include SlackHelper

  before do
    disable_slack_signature_checks!
    incident_started_in('twd_git_bat')
  end

  let(:payload) do
    default_slash_command_payload.merge({
      command: '/incident',
      text: 'close',
      channel_id: channel_id,
      channel_name: channel_id,
    })
  end

  context 'with a valid incident channel' do
    let(:channel_id) { 'incident_channel_id' }
    let(:channel_name) { 'incident_channel_name' }

    it 'returns incident closed confirmation' do
      stub_slack_message(channel: 'incident_channel_id', message: '<!here> This incident has now closed.')
      pin_stub = stub_slack_pin(channel: 'incident_channel_id')
      stub_slack_message(channel: 'twd_git_bat', message: ':white_check_mark: <!channel> The incident in <#incident_channel_id> has now closed.')
      allow(Rails).to receive_message_chain(:cache, :read).and_return('twd_git_bat')

      post '/api/slack/command', params: payload

      expect(a_request(:post, 'https://slack.com/api/chat.postMessage')).to have_been_requested.times(2)
      expect(pin_stub).to have_been_requested
      expect(response.status).to eq 204
    end
  end

  context 'with an invalid incident channel' do
    let(:channel_id) { 'some_other_channel_id' }
    let(:channel_name) { 'some_other_channel_name' }

    it 'returns an error message' do
      user_message_stub = stub_user_message

      post '/api/slack/command', params: payload

      expect(user_message_stub).to have_been_requested
      expect(a_request(:post, 'https://slack.com/api/chat.postMessage')).not_to have_been_made
      expect(a_request(:post, 'https://slack.com/api/pins.add')).not_to have_been_requested
      expect(response.status).to eq 204
    end
  end
end
