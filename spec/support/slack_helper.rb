module SlackHelper
  def default_slash_command_payload
    {
      command: nil,
      text: '`',
      channel_id: 'channel',
      channel_name: 'channel_name',
      user_id: 'user_id',
      team_id: 'team_id',
      token: 'deprecated',
    }
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
