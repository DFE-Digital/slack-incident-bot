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

    incident_start = Time.zone.now.strftime('%y%m%d')
    client = Slack::Web::Client.new(token: ENV['SLACK_TOKEN'])

    create_channel = client.conversations_create(
      name: "incident_#{incident_service.downcase}_#{incident_start}_#{incident_title.parameterize.underscore}", is_private: false,
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
      client.chat_postMessage(channel: 'twd_bat',
                              text: ":rotating_light: <!channel> A new incident has been opened :rotating_light:\n> *Title:* #{incident_title.capitalize} \n>*Priority:* #{incident_priority}\n>*Comms:* <##{channel_name}>")
    end

    threads << Thread.new do
      client.chat_postMessage(channel: 'twd_getintoteaching',
                              text: ":rotating_light: <!channel> A new incident has been opened :rotating_light:\n> *Title:* #{incident_title.capitalize} \n>*Priority:* #{incident_priority}\n>*Comms:* <##{channel_name}>")
    end

    message = client.chat_postMessage(channel: channel_name,
                                      text: "Welcome to the incident channel. Please review the following docs:\n> <#{ENV['INCIDENT_PLAYBOOK']}|Incident playbook> \n><#{ENV['INCIDENT_CATEGORIES']}|Incident categorisation>")
    threads << Thread.new { client.pins_add(channel: channel_name, timestamp: message[:ts]) }

    threads << Thread.new do
      client.chat_postMessage(channel: channel_name,
                              text: "<@#{incident_tech_lead}> please make a copy of the <#{ENV['INCIDENT_TEMPLATE']}|incident template> and consider starting a video call.")
    end

    threads.each(&:join)
  end

  def update_incident(modal_data)
    payload_values = modal_data[:payload][:view][:state][:values]

    new_incident_description = payload_values.dig(:incident_description_block, :incident_description, :value)
    new_incident_priority = payload_values.dig(:incident_priority_block, :incident_priority, :selected_option, :text,
                                               :text)
    new_incident_comms_lead = payload_values.dig(:incident_comms_lead_block, :comms_lead_select_action, :selected_user)
    new_incident_tech_lead = payload_values.dig(:incident_tech_lead_block, :tech_lead_select_action, :selected_user)
    new_incident_support_lead = payload_values.dig(:incident_support_lead_block, :support_lead_select_action,
                                                   :selected_user)

    client = Slack::Web::Client.new(token: ENV['SLACK_TOKEN'])

    channel_name = modal_data[:payload][:response_urls][0][:channel_id]

    current_topic = client.conversations_info(channel: channel_name).dig(:channel, :topic, :value)

    current_topic_clean = current_topic.split("\n").map(&:strip)

    old_incident_description = current_topic_clean[0]
    old_incident_priority = current_topic_clean[1]
    old_incident_comms_lead = current_topic_clean[2]
    old_incident_tech_lead = current_topic_clean[3]
    old_incident_support_lead = current_topic_clean[4]

    description_text = new_incident_description.nil? ? old_incident_description : "Description: #{new_incident_description.capitalize}"
    priority_text = new_incident_priority.nil? ? old_incident_priority : "Priority: #{new_incident_priority}"
    comms_lead_text = new_incident_comms_lead.nil? ? old_incident_comms_lead : "Comms lead: <@#{new_incident_comms_lead}>"
    tech_lead_text = new_incident_tech_lead.nil? ? old_incident_tech_lead : "Tech lead: <@#{new_incident_tech_lead}>"
    support_lead_text = new_incident_support_lead.nil? ? old_incident_support_lead : "Support lead: <@#{new_incident_support_lead}>"

    topic_text = [description_text, priority_text, comms_lead_text, tech_lead_text, support_lead_text].join("\n ")

    current_members = client.conversations_members(channel: channel_name).members

    user_invite_list = []

    user_invite_list << new_incident_comms_lead unless current_members.include? new_incident_comms_lead
    user_invite_list << new_incident_tech_lead unless current_members.include? new_incident_tech_lead
    user_invite_list << new_incident_support_lead unless current_members.include? new_incident_support_lead

    user_invite_list_text = user_invite_list.join(',')

    threads = []
    threads << Thread.new { client.conversations_setTopic(channel: channel_name, topic: topic_text) }

    unless topic_text == current_topic
      threads << Thread.new do
        client.chat_postMessage(channel: channel_name, text: 'Incident has been updated')
      end
    end

    unless user_invite_list.compact.empty?
      threads << Thread.new do
        client.conversations_invite(channel: channel_name, users: user_invite_list_text)
      end
    end

    threads.each(&:join)
  end
end
