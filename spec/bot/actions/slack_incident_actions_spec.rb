require 'rails_helper'

describe 'actions/slack_incident_actions' do
  let(:client) { Slack::Web::Client.new(token: ENV['SLACK_TOKEN']) }
  let(:incident_payload) do
    {
      'payload' => { 'view' =>
          { 'state' =>
            { 'values' =>
              { 'incident_title_block' => { 'incident_title' => { 'type' => 'plain_text_input', 'value' => 'hello' } },
                'incident_description_block' => { 'incident_description' => { 'type' => 'plain_text_input',
                                                                              'value' => 'hello' } },
                'service_selection_block' =>
                { 'service_selection' =>
                  { 'type' => 'static_select',
                    'selected_option' => { 'text' => { 'type' => 'plain_text', 'text' => 'Apply', 'emoji' => true },
                                           'value' => 'value-0' } } },
                'incident_priority_block' =>
                { 'incident_priority' =>
                  { 'type' => 'static_select',
                    'selected_option' =>
                    { 'text' => { 'type' => 'plain_text', 'text' => 'P1 (High) - 60-100% of users affected', 'emoji' => true },
                      'value' => 'value-0' } } },
                'incident_comms_lead_block' => { 'comms_lead_select_action' => { 'type' => 'users_select',
                                                                                 'selected_user' => 'U01RVKPGZDL' } },
                'incident_tech_lead_block' => { 'tech_lead_select_action' => { 'type' => 'users_select',
                                                                               'selected_user' => 'U01RVKPGZDL' } },
                'incident_support_lead_block' => { 'support_lead_select_action' => { 'type' => 'users_select',
                                                                                     'selected_user' => 'U01RVKPGZDL' } } } },
            'app_id' => 'A021D8M1RT9' } },
    }.with_indifferent_access
  end
  let(:channel_id) { { ok: true, channel: { id: 'C018Y6VH39D' } } }
  let(:timestamp) { { ok: true, ts: '1625836853.000800' } }

  it 'performs the incident actions' do
    conversation_stub = stub_request(:post, 'https://slack.com/api/conversations.create').to_return(status: 200, body: channel_id.to_json,
                                                                                                    headers: { 'Content-Type' => 'application/json' })
    invite_stub = stub_request(:post, 'https://slack.com/api/conversations.invite').to_return(status: 200, body: '', headers: {})
    topic_stub = stub_request(:post, 'https://slack.com/api/conversations.setTopic').to_return(status: 200, body: '', headers: {})
    message_stub = stub_request(:post, 'https://slack.com/api/chat.postMessage').to_return(status: 200, body: timestamp.to_json,
                                                                                           headers: { 'Content-Type' => 'application/json' })
    pin_stub = stub_request(:post, 'https://slack.com/api/pins.add').to_return(status: 200, body: '', headers: {})

    SlackIncidentActions.new.open_incident(incident_payload)
    expect(conversation_stub).to have_been_requested
    expect(invite_stub).to have_been_requested
    expect(topic_stub).to have_been_requested
    expect(message_stub).to have_been_requested.times(4)
    expect(pin_stub).to have_been_requested
  end

  it 'sets a topic', vcr: { cassette_name: 'web/conversations_setTopic' } do
    rc = client.conversations_setTopic({ channel: 'C027ZFNML6Q', topic: 'New topic' })
    expect(rc.channel.topic.value).to eq 'New topic'
  end

  it 'posts advice', vcr: { cassette_name: 'web/chat_postMessage_advice' } do
    rc = client.chat_postMessage(channel: 'C027ZFNML6Q',
                                 text: "Welcome to the incident channel. Please review the following docs:\n> <#{ENV['INCIDENT_PLAYBOOK']}|Incident playbook> \n><#{ENV['INCIDENT_CATEGORIES']}|Incident categorisation>")
    expect(rc.message.text).to include 'Welcome to the incident channel.'
  end

  it 'pins a message', vcr: { cassette_name: 'web/pins_add' } do
    rc = client.pins_add({ channel: 'C027ZFNML6Q', timestamp: '1626109416.000300' })
    expect(rc.ok).to eq true
  end

  it 'invites the incident leads', vcr: { cassette_name: 'web/conversations_invite' } do
    rc = client.conversations_invite({ channel: 'C027ZFNML6Q', users: 'U01RVKPGZDL,U01RVKPGZDL,U01RVKPGZDL' })
    expect(rc.ok).to eq true
  end

  it 'posts an alert', vcr: { cassette_name: 'web/chat_postMessage' } do
    rc = client.chat_postMessage({ channel: 'C01RZAVQ6QM', text: 'test' })
    expect(rc.message.text).to include ':rotating_light: &lt;!here&gt; A new incident has been opened :rotating_light:&gt; *Title:* Testing title&gt;*Priority:* P1 (High) - 60-100% of users affected'
  end

  it 'creates a channel', vcr: { cassette_name: 'web/conversations_create' } do
    rc = client.conversations_create({ name: 'incident_apply_210709_hello', is_private: false })
    expect(rc.channel.name).to eq 'incident_apply_210709_hello'
  end
end
