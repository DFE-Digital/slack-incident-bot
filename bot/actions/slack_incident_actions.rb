class SlackIncidentActions
  def open_incident(slack_action, channel_calling_incident)
    incident = SlackIncidentModal.new(slack_action)
    start_time = Time.zone.now.strftime('%y%m%d')
    channel_name = "incident_#{incident.service.downcase}_#{start_time}_#{incident.title.parameterize.underscore}"
    channel = SlackMethods.create_channel!(channel_name)
    channel_id = channel[:channel][:id]

    threads = []

    threads << Thread.new { SlackMethods.invite_users!(channel_id, incident.leads) }
    threads << Thread.new { SlackMethods.set_channel_details!(channel_id, SlackMethods.summary_for(incident)) }
    threads << Thread.new { SlackMethods.introduce_incident!(channel_id, incident.tech_lead) }
    threads << Thread.new { SlackMethods.notify_channel!(channel_calling_incident, channel_id, incident.title, incident.priority) }
    threads << Thread.new { SlackMethods.start_meet!(channel_id) }

    threads.each(&:join)
  end

  def update_incident(slack_action, channel_id)
    incident = SlackUpdateModal.new(slack_action)
    current_summary = SlackMethods.current_summary(channel_id)

    updated_summary = incident.summary_text(current_summary)

    current_members = SlackMethods.current_members(channel_id)

    user_invite_list = incident.create_member_invite_list(current_members)

    threads = []
    unless updated_summary == current_summary
      threads << Thread.new { SlackMethods.set_channel_details!(channel_id, updated_summary) }
      threads << Thread.new { SlackMethods.notify_channel_of_update!(channel_id) }
    end

    unless user_invite_list.compact.empty?
      threads << Thread.new { SlackMethods.invite_users!(channel_id, user_invite_list) }
    end

    threads.each(&:join)
  end
end
