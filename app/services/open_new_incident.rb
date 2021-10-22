class OpenNewIncident
  CHANNELS_TO_NOTIFY = %w[
    twd_bat
    twd_getintoteaching
  ].freeze

  attr_reader :incident

  def initialize(incident:)
    @incident = incident
  end

  def channel_name
    start_time = Time.new.strftime('%y%m%d')
    channel_name = "incident_#{incident.service.downcase}_#{start_time}_#{incident.title.parameterize.underscore}"
  end

  def call
    threads = []

    threads << Thread.new { create_channel!(channel_name) }
    threads << Thread.new { invite_users!(channel_name, incident.leads) }
    threads << Thread.new { set_channel_details!(channel_name, summary_for(incident)) }
    threads << Thread.new { introduce_incident!(channel_name, incident.tech_lead) }

    CHANNELS_TO_NOTIFY.each do |channel_to_notify|
      threads << Thread.new { notify_channel!(channel_to_notify, channel_name, incident.title, incident.priority) }
    end

    threads.each(&:join)
  end

private

  def create_channel!(channel_name)
    slack_client.conversations_create(
      name: channel_name,
      is_private: false
    )
  end

  def invite_users!(channel_name, leads)
    slack_client.conversations_invite(
      channel: channel_name,
      users: leads.join(',')
    )
  end

  def summary_for(incident)
    "Description: #{incident.description.capitalize}\n Priority: #{incident.priority}\n Comms lead: <@#{incident.comms_lead}>\n Tech lead: <@#{incident.tech_lead}>\n Support lead: <@#{incident.support_lead}>"
  end

  def set_channel_details!(channel_name, summary)
    slack_client.conversations_setTopic(
      channel: channel_name,
      topic: summary,
    )
  end

  def notify_channel!(channel, incident_channel_name, title, priority)
    notification_text = ":rotating_light: <!channel> A new incident has been opened :rotating_light:\n> *Title:* #{title.capitalize} \n>*Priority:* #{priority}\n>*Comms:* <##{incident_channel_name}>"

    slack_client.chat_postMessage(channel: channel,
                                  text: notification_text)
  end

  def introduce_incident!(channel_name, tech_lead)
    message = slack_client.chat_postMessage(channel: channel_name,
                                            text: "Welcome to the incident channel. Please review the following docs:\n> <#{ENV['INCIDENT_PLAYBOOK']}|Incident playbook> \n><#{ENV['INCIDENT_CATEGORIES']}|Incident categorisation>")
    slack_client.pins_add(channel: channel_name, timestamp: message[:ts])
    slack_client.chat_postMessage(channel: channel_name, text: "<@#{tech_lead}> please make a copy of the <#{ENV['INCIDENT_TEMPLATE']}|incident template> and consider starting a video call.") 
  end

  def slack_client
    @_client ||= Slack::Web::Client.new(token: ENV['SLACK_TOKEN'])
  end
end
