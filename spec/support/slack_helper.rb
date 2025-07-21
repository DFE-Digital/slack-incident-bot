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

  def stub_slack_open_view(trigger_id:, view_payload:)
    stub_request(:post, 'https://slack.com/api/views.open')
      .with(
        body: hash_including(
          trigger_id: trigger_id,
        ),
        headers: {
          'Accept'=>'application/json; charset=utf-8',
          'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Content-Type'=>'application/x-www-form-urlencoded',
          'User-Agent'=>'Slack Ruby Client/2.7.0'
        }
      )
      .to_return(status: 200, body: dummy_slack_response.to_json, headers: {})
  end

  def stub_slack_ephemeral_error_message(channel:, message:)
    stub_request(:post, 'https://slack.com/api/chat.postEphemeral')
  .with(
    body: { 'channel' => channel, 'text' => message, 'user' => channel },
    headers: {
      'Accept'=>'application/json; charset=utf-8',
      'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
      'Content-Type'=>'application/x-www-form-urlencoded',
      'User-Agent'=>'Slack Ruby Client/2.7.0'
    }
  )
  .to_return(status: 200, body: dummy_slack_response, headers: {})
  end

  def stub_slack_message(channel:, message:)
    stub_request(:post, 'https://slack.com/api/chat.postMessage')
      .with(body: { 'channel' => channel, 'text' => message })
      .to_return(status: 200, body: dummy_slack_response)
  end

  def stub_user_message
    stub_request(:post, 'https://slack.com/api/chat.postEphemeral')
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
