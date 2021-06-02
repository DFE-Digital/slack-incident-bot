SlackRubyBotServer::Events.configure do |config|
  config.on :command, '/incident' do |command|
    p command
    command.logger.info "Someone raised an incident in channel #{command[:channel_id]}."
    slack_connection(command)
    nil
  end
end

def slack_connection(trigger_id, view = incident_payload)
  slack_client = Slack::Web::Client.new(token: ENV['SLACK_TOKEN'])
  slack_client.views_open(trigger_id: trigger_id[:trigger_id], view: view)
end

def incident_payload
  {
      "type": "modal",
      "callback_id": "modal-identifier",
      "title": {
        "type": "plain_text",
        "text": "Raise an incident"
      },
      "submit": {
        "type": "plain_text",
        "text": "Open"
      },
      "close": {
        "type": "plain_text",
        "text": "Cancel",
        "emoji": true
      },
      "blocks": [
        {
          "type": "input",
          "block_id": "incident_title_block",
          "element": {
            "type": "plain_text_input",
            "action_id": "incident_title",
            "placeholder": {
              "type": "plain_text",
              "text": "Enter an incident title"
            }
          },
          "label": {
            "type": "plain_text",
            "text": "Incident title"
          }
        },
        {
          "type": "input",
          "block_id": "incident_description_block",
          "element": {
            "type": "plain_text_input",
            "action_id": "incident_description",
            "multiline": true,
            "placeholder": {
              "type": "plain_text",
              "text": "What is the incident about?"
            }
          },
          "label": {
            "type": "plain_text",
            "text": "Incident description"
          }
        },
        {
          "type": "input",
          "block_id": "service_selection_block",
          "label": {
            "type": "plain_text",
            "text": "Which service is impacted?",
            "emoji": true
          },
          "element": {
            "type": "static_select",
            "action_id": "service_selection",
            "placeholder": {
              "type": "plain_text",
              "text": "Select a service",
              "emoji": true
            },
            "options": [
              {
                "text": {
                  "type": "plain_text",
                  "text": "Apply",
                  "emoji": true
                },
                "value": "value-0"
              },
              {
                "text": {
                  "type": "plain_text",
                  "text": "Find",
                  "emoji": true
                },
                "value": "value-1"
              },
              {
                "text": {
                  "type": "plain_text",
                  "text": "Multiple",
                  "emoji": true
                },
                "value": "value-2"
              },
              {
                "text": {
                  "type": "plain_text",
                  "text": "Other",
                  "emoji": true
                },
                "value": "value-3"
              },
              {
                "text": {
                  "type": "plain_text",
                  "text": "Infrastructure",
                  "emoji": true
                },
                "value": "value-4"
              }
            ]
          }
        },
        {
          "type": "input",
          "block_id": "incident_priority_block",
          "label": {
            "type": "plain_text",
            "text": "What is the incident priority?",
            "emoji": true
          },
          "element": {
            "type": "static_select",
            "action_id": "incident_priority",
            "placeholder": {
              "type": "plain_text",
              "text": "Select a level",
              "emoji": true
            },
            "options": [
              {
                "text": {
                  "type": "plain_text",
                  "text": "P1 (High) - 60-100% of users affected",
                  "emoji": true
                },
                "value": "value-0"
              },
              {
                "text": {
                  "type": "plain_text",
                  "text": "P2 (Medium) - 20-59% of users affected",
                  "emoji": true
                },
                "value": "value-1"
              },
              {
                "text": {
                  "type": "plain_text",
                  "text": "P3 (Low) - <20% of users affected",
                  "emoji": true
                },
                "value": "value-2"
              }
            ]
          }
        },
        {
          "type": "divider"
        },
        {
          "type": "header",
          "text": {
            "type": "plain_text",
            "text": "Incident leads",
            "emoji": true
          }
        },
        {
          "type": "input",
          "block_id": "incident_comms_lead_block",
          "label": {
            "type": "plain_text",
            "text": "Who is the comms lead?",
            "emoji": true
          },
          "element": {
            "type": "users_select",
            "placeholder": {
              "type": "plain_text",
              "text": "Select a user",
              "emoji": true
            },
            "action_id": "comms_lead_select_action"
          }
        },
        {
          "type": "input",
          "block_id": "incident_tech_lead_block",
          "label": {
            "type": "plain_text",
            "text": "Who is the technical lead?",
            "emoji": true
          },
          "element": {
            "type": "users_select",
            "placeholder": {
              "type": "plain_text",
              "text": "Select a user",
              "emoji": true
            },
            "action_id": "tech_lead_select_action"
          }
        },
        {
          "type": "input",
          "block_id": "incident_support_lead_block",
          "label": {
            "type": "plain_text",
            "text": "Who is the support lead?",
            "emoji": true
          },
          "element": {
            "type": "users_select",
            "placeholder": {
              "type": "plain_text",
              "text": "Select a user",
              "emoji": true
            },
            "action_id": "support_lead_select_action"
          }
        }
      ]
  }
end
