require 'rails_helper'

RSpec.describe OpenNewIncident do
  let(:client) { Slack::Web::Client.new(token: ENV['SLACK_TOKEN']) }

  it 'sends appropriate messages to Slack' do

    OpenNewIncident.new(incident, slack_client).call

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
