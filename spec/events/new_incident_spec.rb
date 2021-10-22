require 'rails_helper'

RSpec.describe 'actions/open_new_incident' do
  it 'creates the incident channel and populates it correctly' do
    open_new_incident_params = File.read('spec/fixtures/open_incident.json')

    channel_name = '#incident'
    users = []
    topic = 'bananas'
    message = 'foo'

    stubs = [
      stub_create_channel!(channel_name),
      stub_invite_users!(users),
      stub_set_topic!(channel_name, topic),
      stub_send_message!(channel_name, message),
      stub_send_message!(channel_name, message),
      stub_send_message!(channel_name, message),
      stub_send_message!(channel_name, message),
      stub_pin_message!(channel_name),
    ]

    post('/api/slack/action', params: {payload: open_new_incident_params.to_json})

    expect(stubs).to all have_been_requested
  end

  def stub_create_channel!(channel_name)
    stub_request(:post, 'https://slack.com/api/conversations.create')
      .to_return(
        status: 200,
        body: 'fooooo',
        headers: { 'Content-Type' => 'application/json' })
  end

  def stub_invite_users!(users)
    stub_request(:post, 'https://slack.com/api/conversations.invite').to_return(status: 200, body: '', headers: {})
  end

  def stub_set_topic!(channel_name, topic)
    stub_request(:post, 'https://slack.com/api/conversations.setTopic').to_return(status: 200, body: '', headers: {})
  end

  def stub_send_message!(channel_name, message)
    stub_request( :post, 'https://slack.com/api/chat.postMessage')
      .to_return(status: 200, body: 'sdfsd', headers: { 'Content-Type' => 'application/json' })
  end

  def stub_pin_message!(channel_name)
    stub_request(:post, 'https://slack.com/api/pins.add').to_return(status: 200, body: '', headers: {})
  end
end
