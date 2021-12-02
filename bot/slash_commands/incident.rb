SlackRubyBotServer::Events.configure do |config|
  config.on :command, '/incident' do |command|
    SlackMethods.open_the_modal(command[:trigger_id], incident_payload)
    nil
  end
end

def incident_payload
  JSON.parse(
    File.read(Rails.root.join('lib/view_payloads/incident.json')),
  )
end
