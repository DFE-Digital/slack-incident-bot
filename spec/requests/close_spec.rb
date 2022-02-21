require 'rails_helper'

describe 'slash_commands/close' do
  before do
    disable_slack_signature_checks!
    incident_started_in('twd_git_bat')
  end

  let(:payload) do
    {
      command: '/closeincident',
      text: '`',
      channel_id: channel_id,
      channel_name: channel_id,
      user_id: 'user_id',
      team_id: 'team_id',
      token: 'deprecated',
    }
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

  def incident_started_in(calling_channel)
    allow_any_instance_of(Incident).to receive(:calling_channel).and_return(calling_channel)
  end

  def stub_slack_message(channel:, message:)
    stub_request(:post, 'https://slack.com/api/chat.postMessage')
      .with(body: { 'channel' => channel, 'text' => message })
      .to_return(status: 200, body: dummy_slack_response)
  end

  def stub_slack_pin(channel:)
    stub_request(:post, 'https://slack.com/api/pins.add')
      .with(body: { 'channel' => channel })
      .to_return(status: 200, body: dummy_slack_response)
  end

  def dummy_slack_response
    { ok: true, channel: 'does not matter' }.to_json
  end

  def disable_slack_signature_checks!
    allow_any_instance_of(Slack::Events::Request).to receive(:verify!)
  end
end
