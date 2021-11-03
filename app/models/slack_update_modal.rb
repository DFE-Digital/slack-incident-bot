class SlackUpdateModal
  attr_reader :new_incident_description, :new_incident_priority, :new_incident_comms_lead, :new_incident_tech_lead, :new_incident_support_lead

  def initialize(slack_response)
    payload_from_modal = slack_response[:payload][:view][:state][:values]

    @new_incident_description = payload_from_modal.dig(:incident_description_block, :incident_description, :value)
    @new_incident_priority = payload_from_modal.dig(:incident_priority_block, :incident_priority, :selected_option, :text, :text)
    @new_incident_comms_lead = payload_from_modal.dig(:incident_comms_lead_block, :comms_lead_select_action, :selected_user)
    @new_incident_tech_lead = payload_from_modal.dig(:incident_tech_lead_block, :tech_lead_select_action, :selected_user)
    @new_incident_support_lead = payload_from_modal.dig(:incident_support_lead_block, :support_lead_select_action, :selected_user)
  end

  def summary_text(current_topic)
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

    [description_text, priority_text, comms_lead_text, tech_lead_text, support_lead_text].join("\n ")
  end

  def create_member_invite_list(current_members)
    user_invite_list = []

    user_invite_list << new_incident_comms_lead unless current_members.include? new_incident_comms_lead
    user_invite_list << new_incident_tech_lead unless current_members.include? new_incident_tech_lead
    user_invite_list << new_incident_support_lead unless current_members.include? new_incident_support_lead

    user_invite_list
  end
end
