require 'rails_helper'

describe 'actions/slack_incident_actions' do
  include SlackHelper

  let(:client) { Slack::Web::Client.new(token: ENV['SLACK_TOKEN']) }

  let(:incident_payload) do
    JSON.parse(File.read('spec/examples/incident_payload.json'))
  end

  let(:update_payload) do
    JSON.parse(File.read('spec/examples/update_payload.json'))
  end

  before do
    disable_slack_signature_checks!
    incident_started_in('twd_git_bat')
    current_incident_channel('apply_1234')
  end

  around do |ex|
    ClimateControl.modify SLACK_APP_ID: 'TEST_APP_ID' do
      ex.run
    end
  end

  it 'performs the incident actions' do
    channel_creation_requests = stub_slack_channel_creation(
      channel: 'incident_apply_220221_hello',
      users: %w(COMMS_LEAD TECH_LEAD SUPPORT_LEAD),
      topic: "Description: Hello\n Priority: P1 (High) - 60-100% of users affected\n Comms lead: <@COMMS_LEAD>\n Tech lead: <@TECH_LEAD>\n Support lead: <@SUPPORT_LEAD>",
    )

    channel_message_requests = stub_slack_messages(
      channel: 'incident_apply_220221_hello',
      messages: [
        'Join the <|incident call.>',
        "Welcome to the incident channel. Please review the following docs:\n> <|Incident playbook> \n><|Incident categorisation>",
        '<@TECH_LEAD> please make a copy of the <|incident template>.'
      ]
    )

    public_announcement = stub_slack_message(channel: 'twd_git_bat', message: ":rotating_light: <!channel> A new incident has been opened :rotating_light:\n> *Title:* Hello \n>*Priority:* P1 (High) - 60-100% of users affected\n>*Comms:* <#incident_apply_220221_hello>")
    stub_slack_pin(channel: 'incident_apply_220221_hello')

    post '/api/slack/action', params: incident_payload

    expect(channel_creation_requests).to all have_been_made
    expect(channel_message_requests).to all have_been_made
    expect(public_announcement).to have_been_made
  end

  it 'performs the update action' do
    stub_slack_conversation_info(channel: 'apply_1234')
    stub_slack_conversation_members(channel: 'apply_1234', users: %w(COMMS_LEAD TECH_LEAD SUPPORT_LEAD))
    stub_slack_topic(channel: 'apply_1234', topic: "A topic\n \n \n \n Support lead: <@NEW_SUPPORT_LEAD>")
    stub_slack_message(channel: 'apply_1234', message: 'Incident has been updated')
    stub_slack_invitation(channel: 'apply_1234', users: [nil,nil,'NEW_SUPPORT_LEAD'])

    post '/api/slack/action', params: update_payload
  end
end
