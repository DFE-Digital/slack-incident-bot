class SlackIncidentModal
  attr_reader :title, :description, :service, :priority, :comms_lead, :tech_lead, :support_lead, :slack_response

  def initialize(slack_response)
    @slack_response = slack_response
    payload_from_modal = slack_response[:payload][:view][:state][:values]

    @title = payload_from_modal[:incident_title_block][:incident_title][:value]
    @description = payload_from_modal[:incident_description_block][:incident_description][:value]
    @service = payload_from_modal[:service_selection_block][:service_selection][:selected_option][:text][:text]
    @priority = payload_from_modal[:incident_priority_block][:incident_priority][:selected_option][:text][:text]
    @comms_lead = payload_from_modal[:incident_comms_lead_block][:comms_lead_select_action][:selected_user]
    @tech_lead = payload_from_modal[:incident_tech_lead_block][:tech_lead_select_action][:selected_user]
    @support_lead = payload_from_modal[:incident_support_lead_block][:support_lead_select_action][:selected_user]
  end

  def leads
    [@comms_lead, @tech_lead, @support_lead]
  end

  def declarer
    slack_response[:payload][:user][:id]
  end
end
