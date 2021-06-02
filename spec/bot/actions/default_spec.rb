require 'rails_helper'

describe 'actions/default' do
  include Rack::Test::Methods

  def app
    SlackRubyBotServer::Api::Middleware.instance
  end

  context 'without signature checks' do
    before do
      allow_any_instance_of(Slack::Events::Request).to receive(:verify!)
    end

    let(:action) do
      {
        payload: {
          "type":"view_submission",
          "team":{
            "id":"T01SF1W8V17",
            "domain":"slackbottesti-00o2598"
          },
          "user":{
            "id":"U01RVKPGZDL",
            "username":"jg",
            "name":"jg",
            "team_id":"T01SF1W8V17"
          },
          "api_app_id":"A021D8M1RT9",
          "token":"token",
          "trigger_id":"2118768502486.1899064301041.0f6a5ed3cf247e69c2945703e5f3db6e",
          "view":{
            "id":"V023PG2AVTL",
            "team_id":"T01SF1W8V17",
            "type":"modal",
            "private_metadata":"",
            "callback_id":"modal-identifier",
            "state":{
                "values":{
                  "incident_title_block":{
                      "incident_title":{
                        "type":"plain_text_input",
                        "value":"hello"
                      }
                  },
                  "incident_description_block":{
                      "incident_description":{
                        "type":"plain_text_input",
                        "value":"hello"
                      }
                  },
                  "incident_priority_block":{
                      "incident_priority":{
                        "type":"static_select",
                        "selected_option":{
                            "text":{
                              "type":"plain_text",
                              "text":"P1 (High) - 60-100% of users affected",
                              "emoji":true
                            },
                            "value":"value-0"
                        }
                      }
                  },
                  "incident_comms_lead_block":{
                      "comms_lead_select_action":{
                        "type":"users_select",
                        "selected_user":"U01RVKPGZDL"
                      }
                  },
                  "incident_tech_lead_block":{
                      "tech_lead_select_action":{
                        "type":"users_select",
                        "selected_user":"U01RVKPGZDL"
                      }
                  },
                  "incident_support_lead_block":{
                      "support_lead_select_action":{
                        "type":"users_select",
                        "selected_user":"U01RVKPGZDL"
                      }
                  }
                }
            },
            "title":{
                "type":"plain_text",
                "text":"Raise an incident",
                "emoji":true
            },
            "clear_on_close":false,
            "notify_on_close":false,
            "close":{
                "type":"plain_text",
                "text":"Cancel",
                "emoji":true
            },
            "submit":{
                "type":"plain_text",
                "text":"Open",
                "emoji":true
            },
          },
        }
     }
    end

    it 'creates a channel' do
      expect_any_instance_of(Logger).to receive(:info).with('Received view_submission.')
      post '/api/slack/action', action
      expect(last_response.status).to eq 204
    end
  end
end