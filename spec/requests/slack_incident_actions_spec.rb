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

  let(:update_payload) do
    {
      'payload' => { view: {
        state: {
          values: {
            incident_support_lead_block: {
              support_lead_select_action: {
                type: 'users_select',
                selected_user: 'U027SPH3TKP',
              },
            },
          },
        },
      } },
    }.with_indifferent_access
  end

  let(:channel_id) { { ok: true, channel: { id: 'C018Y6VH39D' } } }
  let(:timestamp) { { ok: true, ts: '1625836853.000800' } }
  let(:conversation_info) { { ok: true, channel: { topic: { value: 'Description: Test\n Priority: P2 (Medium) - 20-59% of users affected\n Comms lead: <@U01RVKPGZDL>\n Tech lead: <@U01RVKPGZDL>\n Support lead: <@U01RVKPGZDL>' } } } }
  let(:current_members) { { 'ok' => true, 'members' => %w[U01RVKPGZDL U0224J2AHJP U01RVKPGZDL] } }
  let(:members_invite) { { 'ok' => true, 'channel' => { 'topic' => { 'value' => "Description: Again\n Priority: P2 (Medium) - 20-59% of users affected\n Comms lead: <@U01RVKPGZDL>\n Tech lead: <@U01RVKPGZDL>\n Support lead: <@U027SPH3TKP>" } } } }

  it 'performs the incident actions' do
    conversation_stub = stub_request(:post, 'https://slack.com/api/conversations.create').to_return(status: 200, body: channel_id.to_json,
                                                                                                    headers: { 'Content-Type' => 'application/json' })
    invite_stub = stub_request(:post, 'https://slack.com/api/conversations.invite').to_return(status: 200, body: '', headers: {})
    topic_stub = stub_request(:post, 'https://slack.com/api/conversations.setTopic').to_return(status: 200, body: '', headers: {})
    message_stub = stub_request(:post, 'https://slack.com/api/chat.postMessage').to_return(status: 200, body: timestamp.to_json,
                                                                                           headers: { 'Content-Type' => 'application/json' })
    pin_stub = stub_request(:post, 'https://slack.com/api/pins.add').to_return(status: 200, body: '', headers: {})

    SlackIncidentActions.new.open_incident(incident_payload, channel_id)
    expect(conversation_stub).to have_been_requested
    expect(invite_stub).to have_been_requested
    expect(topic_stub).to have_been_requested
    expect(message_stub).to have_been_requested.times(4)
    expect(pin_stub).to have_been_requested.times(2)
  end

  it 'performs the update action' do
    conversation_info_stub = stub_request(:post, 'https://slack.com/api/conversations.info').to_return(
      status: 200,
      body: conversation_info.to_json,
      headers: { 'Content-Type' => 'application/json' },
    )

    conversation_members_stub = stub_request(:post, 'https://slack.com/api/conversations.members').to_return(
      status: 200,
      body: current_members.to_json,
      headers: { 'Content-Type' => 'application/json' },
    )

    conversation_topic_stub = stub_request(:post, 'https://slack.com/api/conversations.setTopic').to_return(
      status: 200,
      body: '',
      headers: {},
    )

    post_message_stub = stub_request(:post, 'https://slack.com/api/chat.postMessage').to_return(
      status: 200,
      body: timestamp.to_json,
      headers: { 'Content-Type' => 'application/json' },
    )

    conversation_invite_stub = stub_request(:post, 'https://slack.com/api/conversations.invite').to_return(
      status: 200,
      body: members_invite.to_json,
      headers: { 'Content-Type' => 'application/json' },
    )

    SlackIncidentActions.new.update_incident(update_payload, channel_id)
    expect(conversation_info_stub).to have_been_requested
    expect(conversation_members_stub).to have_been_requested
    expect(conversation_topic_stub).to have_been_requested
    expect(post_message_stub).to have_been_requested
    expect(conversation_invite_stub).to have_been_requested
  end
end
