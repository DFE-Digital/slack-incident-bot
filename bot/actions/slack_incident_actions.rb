class SlackIncidentActions
  def open_incident(modal_data)
    payload_values = modal_data[:payload][:view][:state][:values]
    incident_title = payload_values[:incident_title_block][:incident_title][:value]
    incident_description = payload_values[:incident_description_block][:incident_description][:value]
    incident_service = payload_values[:service_selection_block][:service_selection][:selected_option][:text][:text]
    incident_priority = payload_values[:incident_priority_block][:incident_priority][:selected_option][:text][:text]
    incident_comms_lead = payload_values[:incident_comms_lead_block][:comms_lead_select_action][:selected_user]
    incident_tech_lead = payload_values[:incident_tech_lead_block][:tech_lead_select_action][:selected_user]
    incident_support_lead = payload_values[:incident_support_lead_block][:support_lead_select_action][:selected_user]

    incident_start = Time.new.strftime('%y%m%d')
    client = Slack::Web::Client.new(token: ENV['SLACK_TOKEN'])

    create_channel = client.conversations_create(
      name: "incident_#{incident_service.downcase}_#{incident_start}_#{incident_title.parameterize.underscore}", is_private: false
    )
    channel_name = create_channel[:channel][:id]

    threads = []
    threads << Thread.new do
      client.conversations_invite(channel: channel_name,
                                  users: "#{incident_comms_lead},#{incident_tech_lead},#{incident_support_lead}")
    end
    threads << Thread.new do
      client.conversations_setTopic(channel: channel_name,
                                    topic: "Description: #{incident_description.capitalize}\n Priority: #{incident_priority}\n Comms lead: <@#{incident_comms_lead}>\n Tech lead: <@#{incident_tech_lead}>\n Support lead: <@#{incident_support_lead}>")
    end
    threads << Thread.new do
      client.chat_postMessage(channel: 'general',
                              text: ":rotating_light: <!here> A new incident has been opened :rotating_light:\n> *Title:* #{incident_title.capitalize} \n>*Priority:* #{incident_priority}\n>*Comms:* <##{channel_name}>")
    end

    message = client.chat_postMessage(channel: channel_name,
                                      text: "Welcome to the incident channel. Please review the following docs:\n> <https://docs.google.com/document/d/1QN72Gom-M6bysVqC8Enq0crOqE_cFT82tBfMy1djF6s/edit#heading=h.pu6me2z5fcxt|Incident playbook> \n><https://docs.google.com/document/d/1uUeoUiXejyB5XnVjWniDvX3nzoxdRj1I/edit|Incident categorisation>")
    threads << Thread.new { client.pins_add(channel: channel_name, timestamp: message[:ts]) }

    threads.each(&:join)
  end
end
