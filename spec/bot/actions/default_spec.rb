require 'rails_helper'

describe 'actions/default' do
  include Rack::Test::Methods
  let(:client) { Slack::Web::Client.new }

  def app
    SlackRubyBotServer::Api::Middleware.instance
  end

  it 'checks signature' do
    post '/api/slack/action'
    expect(last_response.status).to eq 403
    response = JSON.parse(last_response.body)
    expect(response).to eq('error' => 'Invalid Signature')
  end

  context 'chat_postMessage' do
    it 'automatically converts attachments and blocks into JSON' do
      expect(client).to receive(:post).with(
        'chat.postMessage',
        channel: 'channel',
        text: 'text',
        attachments: '[]',
        blocks: '[]'
      )
      client.chat_postMessage(channel: 'channel', text: 'text', attachments: [], blocks: [])
    end
    context 'text, attachment and blocks arguments' do
      it 'requires text, attachments or blocks' do
        expect { client.chat_postMessage(channel: 'channel') }.to(
          raise_error(ArgumentError, /Required arguments :text, :attachments or :blocks missing/)
        )
      end
      it 'only text' do
        expect(client).to receive(:post).with('chat.postMessage', hash_including(text: 'text'))
        expect { client.chat_postMessage(channel: 'channel', text: 'text') }.not_to raise_error
      end
      it 'only attachments' do
        expect(client).to receive(:post).with('chat.postMessage', hash_including(attachments: '[]'))
        expect { client.chat_postMessage(channel: 'channel', attachments: []) }.not_to raise_error
      end
      it 'only blocks' do
        expect(client).to receive(:post).with('chat.postMessage', hash_including(blocks: '[]'))
        expect { client.chat_postMessage(channel: 'channel', blocks: []) }.not_to raise_error
      end
      it 'all text, attachments and blocks' do
        expect(client).to(
          receive(:post)
            .with('chat.postMessage', hash_including(text: 'text', attachments: '[]', blocks: '[]'))
        )
        expect do
          client.chat_postMessage(channel: 'channel', text: 'text', attachments: [], blocks: [])
        end.not_to raise_error
      end
    end
  end

  context 'without signature checks' do
    before do
      allow_any_instance_of(Slack::Events::Request).to receive(:verify!)
    end

    context 'with a team' do
      let!(:team) { Fabricate(:team) }
      let(:trigger_id) { '12345.98765.abcd2358fdea' }
      let(:payload) do
        {
            "type"=>"view_submission",
            "response_url"=>"https://hooks.slack.com/api/path/to/hook",
            "team"=>{"id"=>"T01SF1W8V17", "domain"=>"slackbottesti-00o2598"},
            "user"=>{"id"=>"U01RVKPGZDL", "username"=>"james.glenn", "name"=>"james.glenn", "team_id"=>"T01SF1W8V17"},
            "api_app_id"=>"A021D8M1RT9",
            "token"=>"token",
            "trigger_id"=>trigger_id,
            "view"=>
             {"id"=>"V024L85HL3S",
              "team_id"=>"T01SF1W8V17",
              "type"=>"modal",
              "blocks"=>
               [{"type"=>"input",
                 "block_id"=>"incident_title_block",
                 "label"=>{"type"=>"plain_text", "text"=>"Incident title", "emoji"=>true},
                 "optional"=>false,
                 "dispatch_action"=>false,
                 "element"=>
                  {"type"=>"plain_text_input",
                   "action_id"=>"incident_title",
                   "placeholder"=>{"type"=>"plain_text", "text"=>"Enter an incident title", "emoji"=>true},
                   "dispatch_action_config"=>{"trigger_actions_on"=>["on_enter_pressed"]}}},
                {"type"=>"input",
                 "block_id"=>"incident_description_block",
                 "label"=>{"type"=>"plain_text", "text"=>"Incident description", "emoji"=>true},
                 "optional"=>false,
                 "dispatch_action"=>false,
                 "element"=>
                  {"type"=>"plain_text_input",
                   "action_id"=>"incident_description",
                   "placeholder"=>{"type"=>"plain_text", "text"=>"What is the incident about?", "emoji"=>true},
                   "multiline"=>true,
                   "dispatch_action_config"=>{"trigger_actions_on"=>["on_enter_pressed"]}}},
                {"type"=>"input",
                 "block_id"=>"service_selection_block",
                 "label"=>{"type"=>"plain_text", "text"=>"Which service is impacted?", "emoji"=>true},
                 "optional"=>false,
                 "dispatch_action"=>false,
                 "element"=>
                  {"type"=>"static_select",
                   "action_id"=>"service_selection",
                   "placeholder"=>{"type"=>"plain_text", "text"=>"Select a service", "emoji"=>true},
                   "options"=>
                    [{"text"=>{"type"=>"plain_text", "text"=>"Apply", "emoji"=>true}, "value"=>"value-0"},
                     {"text"=>{"type"=>"plain_text", "text"=>"Find", "emoji"=>true}, "value"=>"value-1"},
                     {"text"=>{"type"=>"plain_text", "text"=>"Multiple", "emoji"=>true}, "value"=>"value-2"},
                     {"text"=>{"type"=>"plain_text", "text"=>"Other", "emoji"=>true}, "value"=>"value-3"},
                     {"text"=>{"type"=>"plain_text", "text"=>"Infrastructure", "emoji"=>true}, "value"=>"value-4"}]}},
                {"type"=>"input",
                 "block_id"=>"incident_priority_block",
                 "label"=>{"type"=>"plain_text", "text"=>"What is the incident priority?", "emoji"=>true},
                 "optional"=>false,
                 "dispatch_action"=>false,
                 "element"=>
                  {"type"=>"static_select",
                   "action_id"=>"incident_priority",
                   "placeholder"=>{"type"=>"plain_text", "text"=>"Select a level", "emoji"=>true},
                   "options"=>
                    [{"text"=>{"type"=>"plain_text", "text"=>"P1 (High) - 60-100% of users affected", "emoji"=>true}, "value"=>"value-0"},
                     {"text"=>{"type"=>"plain_text", "text"=>"P2 (Medium) - 20-59% of users affected", "emoji"=>true}, "value"=>"value-1"},
                     {"text"=>{"type"=>"plain_text", "text"=>"P3 (Low) - <20% of users affected", "emoji"=>true}, "value"=>"value-2"}]}},
                {"type"=>"divider", "block_id"=>"z8a"},
                {"type"=>"header", "block_id"=>"BbV", "text"=>{"type"=>"plain_text", "text"=>"Incident leads", "emoji"=>true}},
                {"type"=>"input",
                 "block_id"=>"incident_comms_lead_block",
                 "label"=>{"type"=>"plain_text", "text"=>"Who is the comms lead?", "emoji"=>true},
                 "optional"=>false,
                 "dispatch_action"=>false,
                 "element"=>
                  {"type"=>"users_select",
                   "action_id"=>"comms_lead_select_action",
                   "placeholder"=>{"type"=>"plain_text", "text"=>"Select a user", "emoji"=>true}}},
                {"type"=>"input",
                 "block_id"=>"incident_tech_lead_block",
                 "label"=>{"type"=>"plain_text", "text"=>"Who is the technical lead?", "emoji"=>true},
                 "optional"=>false,
                 "dispatch_action"=>false,
                 "element"=>
                  {"type"=>"users_select",
                   "action_id"=>"tech_lead_select_action",
                   "placeholder"=>{"type"=>"plain_text", "text"=>"Select a user", "emoji"=>true}}},
                {"type"=>"input",
                 "block_id"=>"incident_support_lead_block",
                 "label"=>{"type"=>"plain_text", "text"=>"Who is the support lead?", "emoji"=>true},
                 "optional"=>false,
                 "dispatch_action"=>false,
                 "element"=>
                  {"type"=>"users_select",
                   "action_id"=>"support_lead_select_action",
                   "placeholder"=>{"type"=>"plain_text", "text"=>"Select a user", "emoji"=>true}}}],
              "private_metadata"=>"",
              "callback_id"=>"incident-modal-identifier",
              "state"=>
               {"values"=>
                 {"incident_title_block"=>{"incident_title"=>{"type"=>"plain_text_input", "value"=>"hello"}},
                  "incident_description_block"=>{"incident_description"=>{"type"=>"plain_text_input", "value"=>"hello"}},
                  "service_selection_block"=>
                   {"service_selection"=>
                     {"type"=>"static_select",
                      "selected_option"=>{"text"=>{"type"=>"plain_text", "text"=>"Apply", "emoji"=>true}, "value"=>"value-0"}}},
                  "incident_priority_block"=>
                   {"incident_priority"=>
                     {"type"=>"static_select",
                      "selected_option"=>
                       {"text"=>{"type"=>"plain_text", "text"=>"P1 (High) - 60-100% of users affected", "emoji"=>true}, "value"=>"value-0"}}},
                  "incident_comms_lead_block"=>{"comms_lead_select_action"=>{"type"=>"users_select", "selected_user"=>"U01RVKPGZDL"}},
                  "incident_tech_lead_block"=>{"tech_lead_select_action"=>{"type"=>"users_select", "selected_user"=>"U01RVKPGZDL"}},
                  "incident_support_lead_block"=>{"support_lead_select_action"=>{"type"=>"users_select", "selected_user"=>"U01RVKPGZDL"}}}},
              "hash"=>"1622713899.bVAUeZl7",
              "title"=>{"type"=>"plain_text", "text"=>"Raise an incident", "emoji"=>true},
              "clear_on_close"=>false,
              "notify_on_close"=>false,
              "close"=>{"type"=>"plain_text", "text"=>"Cancel", "emoji"=>true},
              "submit"=>{"type"=>"plain_text", "text"=>"Open", "emoji"=>true},
              "previous_view_id"=>nil,
              "root_view_id"=>"V024L85HL3S",
              "app_id"=>"A021D8M1RT9",
              "external_id"=>"",
              "app_installed_team_id"=>"T01SF1W8V17",
              "bot_id"=>"B022U61DV7S"},
            "is_enterprise_install"=>false,
            "enterprise"=>nil
      }
      end

      it 'logs the action' do
        expect_any_instance_of(Logger).to receive(:info).with('Received view_submission.')
        post '/api/slack/action', payload: payload.to_json
        expect(last_response.status).to eq 204
      end
    end
  end
end