class SlackMethods
  def self.post_a_message(channel, text)
    slack_client.chat_postMessage(
      channel: channel,
      text: text,
    )
  end

  def self.pin_a_message(channel, timestamp)
    slack_client.pins_add(
      channel: channel,
      timestamp: timestamp,
    )
  end

  def self.post_a_message_to_user(channel, user, text)
    slack_client.chat_postEphemeral(
      channel: channel,
      user: user,
      text: text,
    )
  end

  def self.current_summary(channel_id)
    slack_client.conversations_info(
      channel: channel_id,
    ).dig(:channel, :topic, :value)
  end

  def self.current_members(channel_id)
    slack_client.conversations_members(
      channel: channel_id,
    ).members
  end

  def self.create_channel!(channel_name)
    slack_client.conversations_create(
      name: channel_name,
      is_private: false,
    )
  end

  def self.invite_users!(channel_id, leads)
    slack_client.conversations_invite(
      channel: channel_id,
      users: leads.join(','),
    )
  end

  def self.summary_for(incident)
    "Description: #{incident.description.capitalize}\n Priority: #{incident.priority}\n Comms lead: <@#{incident.comms_lead}>\n Tech lead: <@#{incident.tech_lead}>\n Support lead: <@#{incident.support_lead}>"
  end

  def self.set_channel_details!(channel_id, summary)
    slack_client.conversations_setTopic(
      channel: channel_id,
      topic: summary,
    )
  end

  def self.notify_channel!(channel, incident_channel_id, title, priority)
    notification_text = ":rotating_light: <!channel> A new incident has been opened :rotating_light:\n> *Title:* #{title.capitalize} \n>*Priority:* #{priority}\n>*Comms:* <##{incident_channel_id}>"

    slack_client.chat_postMessage(channel: channel,
                                  text: notification_text)
  end

  def self.notify_channel_of_update!(channel_id)
    slack_client.chat_postMessage(channel: channel_id,
                                  text: 'Incident has been updated')
  end

  def self.introduce_incident!(channel_id, tech_lead)
    message = slack_client.chat_postMessage(channel: channel_id,
                                            text: "Welcome to the incident channel. Please review the following docs:\n> <#{ENV.fetch('INCIDENT_PLAYBOOK', nil)}|Incident playbook> \n><#{ENV.fetch('INCIDENT_CATEGORIES', nil)}|Incident categorisation>")
    slack_client.pins_add(channel: channel_id, timestamp: message[:ts])
    slack_client.chat_postMessage(channel: channel_id, text: "<@#{tech_lead}> please make a copy of the <#{ENV.fetch('INCIDENT_TEMPLATE', nil)}|incident template>.")
  end

  def self.open_the_modal(trigger_id, view_payload)
    slack_client.views_open(
      trigger_id: trigger_id,
      view: view_payload,
    )
  end

  def self.slack_client
    @_client = Slack::Web::Client.new(token: ENV.fetch('SLACK_TOKEN', nil))
  end
end
