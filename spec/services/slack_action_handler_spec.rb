require 'rails_helper'

describe SlackActionHandler do
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
            'app_id' => 'A021D8M1RT9' } }
    }.with_indifferent_access
  end
  let(:channel_id) { { "ok": true, "channel": { "id": 'C018Y6VH39D' } } }
  let(:timestamp) { { "ok": true, "ts": '1625836853.000800' } }

  it 'creates a new incident actions' do
    conversation_stub = stub_request(:post, 'https://slack.com/api/conversations.create').to_return(status: 200, body: channel_id.to_json,
                                                                                headers: { 'Content-Type' => 'application/json' })
    invite_stub = stub_request(:post, 'https://slack.com/api/conversations.invite').to_return(status: 200, body: '', headers: {})
    topic_stub = stub_request(:post, 'https://slack.com/api/conversations.setTopic').to_return(status: 200, body: '', headers: {})
    message_stub = stub_request(:post, 'https://slack.com/api/chat.postMessage').to_return(status: 200, body: timestamp.to_json,
                                                                            headers: { 'Content-Type' => 'application/json' })
    pin_stub = stub_request(:post, 'https://slack.com/api/pins.add').to_return(status: 200, body: '', headers: {})

    SlackActionHandler.new(incident_payload).call
    expect(conversation_stub).to have_been_requested
    expect(invite_stub).to have_been_requested
    expect(topic_stub).to have_been_requested
    expect(message_stub).to have_been_requested.times(4)
    expect(pin_stub).to have_been_requested
  end
end
