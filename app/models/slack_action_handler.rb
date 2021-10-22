class SlackActionHandler
  def initialize(slack_action)
    @action = slack_action
  end

  def call
    begin
      binding.pry
      if for_our_app?
        incident = SlackIncidentModal.new(action)
        OpenNewIncident.new(incident: incident).call
      end
    rescue Slack::Web::Api::Errors::NameTaken => e
      slack_client.chat_postEphemeral(channel: action[:payload][:user][:id], user: action[:payload][:user][:id],
                                      text: 'That incident channel name has already been taken. Please try another.')
    rescue Slack::Web::Api::Errors::CantInviteSelf => e
      slack_client.chat_postEphemeral(channel: action[:payload][:user][:id], user: action[:payload][:user][:id],
                                      text: 'You can’t invite the bot to the channel. You’ll need to manually add the leads now.')
    end
  end

private

  attr_reader :action

  def for_our_app?
    action[:payload][:view][:app_id] == ENV['SLACK_APP_ID']
  end

  def slack_client
    @_slack_client ||= Slack::Web::Client.new(token: ENV['SLACK_TOKEN'])
  end
end
