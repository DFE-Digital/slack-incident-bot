class SlackIncidentActions
  CHANNELS_TO_NOTIFY = %w[
    twd_bat
    twd_getintoteaching
  ].freeze

  def open_incident(slack_action)
    incident = SlackIncidentModal.new(slack_action)
    start_time = Time.zone.now.strftime('%y%m%d')
    channel_name = "incident_#{incident.service.downcase}_#{start_time}_#{incident.title.parameterize.underscore}"
    channel = create_channel!(channel_name)
    channel_id = channel[:channel][:id]

    threads = []

    threads << Thread.new { invite_users!(channel_id, incident.leads) }
    threads << Thread.new { set_channel_details!(channel_id, summary_for(incident)) }
    threads << Thread.new { introduce_incident!(channel_id, incident.tech_lead) }

    CHANNELS_TO_NOTIFY.each do |channel_to_notify|
      threads << Thread.new { notify_channel!(channel_to_notify, channel_id, incident.title, incident.priority) }
    end

    threads.each(&:join)
  end

private

  def create_channel!(channel_name)
    slack_client.conversations_create(
      name: channel_name,
      is_private: false,
    )
  end

  def invite_users!(channel_id, leads)
    slack_client.conversations_invite(
      channel: channel_id,
      users: leads.join(','),
    )
  end

  def summary_for(incident)
    "Description: #{incident.description.capitalize}\n Priority: #{incident.priority}\n Comms lead: <@#{incident.comms_lead}>\n Tech lead: <@#{incident.tech_lead}>\n Support lead: <@#{incident.support_lead}>"
  end

  def set_channel_details!(channel_id, summary)
    slack_client.conversations_setTopic(
      channel: channel_id,
      topic: summary,
    )
  end

  def notify_channel!(channel, incident_channel_id, title, priority)
    notification_text = ":rotating_light: <!channel> A new incident has been opened :rotating_light:\n> *Title:* #{title.capitalize} \n>*Priority:* #{priority}\n>*Comms:* <##{incident_channel_id}>"

    slack_client.chat_postMessage(channel: channel,
                                  text: notification_text)
  end

  def introduce_incident!(channel_id, tech_lead)
    message = slack_client.chat_postMessage(channel: channel_id,
                                            text: "Welcome to the incident channel. Please review the following docs:\n> <#{ENV['INCIDENT_PLAYBOOK']}|Incident playbook> \n><#{ENV['INCIDENT_CATEGORIES']}|Incident categorisation>")
    slack_client.pins_add(channel: channel_id, timestamp: message[:ts])
    slack_client.chat_postMessage(channel: channel_id, text: "<@#{tech_lead}> please make a copy of the <#{ENV['INCIDENT_TEMPLATE']}|incident template> and consider starting a video call.")
  end

  def slack_client
    @_client ||= Slack::Web::Client.new(token: ENV['SLACK_TOKEN'])
  end
end
