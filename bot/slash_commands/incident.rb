SlackRubyBotServer::Events.configure do |config|
  config.on :command, '/incident' do |command|
    p command
    command.logger.info "Someone raised an incident in channel #{command[:channel_name]}."
    slack_connection(command)
    nil
  end
end

def slack_connection(trigger_id, view = incident_payload)
  slack_client = Slack::Web::Client.new(token: ENV['SLACK_TOKEN'])
  slack_client.views_open(trigger_id: trigger_id[:trigger_id], view: view)
end

def incident_payload
  JSON.parse(
    File.read(Rails.root.join("lib/view_payloads/incident.json"))
  )
end
