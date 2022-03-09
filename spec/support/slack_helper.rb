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

  def current_incident_channel(channel)
    allow_any_instance_of(Incident).to receive(:channel_id).and_return(channel)
  end

  def incident_started_in(calling_channel)
    allow_any_instance_of(Incident).to receive(:calling_channel).and_return(calling_channel)
  end

  def stub_slack_open_view(trigger_id:, view_payload:)
    stub_request(:post, 'https://slack.com/api/views.open')
      .with(body: { 'trigger_id' => trigger_id, 'view' => view_payload })
      .to_return(status: 200, body: dummy_slack_response)
  end

  def stub_slack_message(channel:, message:)
    stub_request(:post, 'https://slack.com/api/chat.postMessage')
      .with(body: { 'channel' => channel, 'text' => message })
      .to_return(status: 200, body: dummy_slack_response)
  end

  def stub_slack_channel_creation(channel:, topic:, users:)
    [ stub_slack_create_conversation(channel: channel),
      stub_slack_topic(channel: channel, topic: topic),
      stub_slack_invitation(channel: channel, users: users) ]
  end

  def stub_slack_messages(channel:, messages:)
    messages.map do |message|
      stub_slack_message(channel: channel, message: message)
    end
  end

  def stub_slack_create_conversation(channel:)
    stub_request(:post, 'https://slack.com/api/conversations.create')
      .with(body: { 'is_private' => false, 'name' => channel })
      .to_return(status: 200, body: { ok: true, channel: { id: channel } }.to_json)
  end

  def stub_slack_invitation(channel:, users: [])
    stub_request(:post, 'https://slack.com/api/conversations.invite')
      .with(body: { 'users' => users.join(','), 'channel' => channel })
      .to_return(status: 200, body: { ok: true, channel: { id: channel } }.to_json)
  end

  def stub_slack_topic(channel:, topic:)
    stub_request(:post, 'https://slack.com/api/conversations.setTopic')
      .with(body: { 'topic' => topic, 'channel' => channel })
      .to_return(status: 200, body: { ok: true, channel: { id: channel } }.to_json)
  end

  def stub_slack_pin(channel:)
    stub_request(:post, 'https://slack.com/api/pins.add')
      .with(body: { 'channel' => channel })
      .to_return(status: 200, body: dummy_slack_response)
  end

  def stub_slack_conversation_info(channel:)
    stub_request(:post, 'https://slack.com/api/conversations.info')
      .with(body: { 'channel' => channel })
      .to_return(status: 200, body: dummy_slack_response)
  end

  def stub_slack_conversation_members(channel:, users: [])
    stub_request(:post, 'https://slack.com/api/conversations.members')
      .with(body: { 'channel' => channel })
      .to_return(status: 200, body: { ok: true, members: users }.to_json)
  end

  def dummy_slack_response
    { ok: true, channel: { topic: { value: 'A topic' } } }.to_json
  end

  def disable_slack_signature_checks!
    allow_any_instance_of(Slack::Events::Request).to receive(:verify!)
  end
end
