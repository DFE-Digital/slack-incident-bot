SlackRubyBotServer::Events.configure do |config|
  config.on :command, '/incident' do |command|
    case command[:text]
    when 'open'
      IncidentCommands::Open.perform(command)
      nil
    when 'update'
      IncidentCommands::Update.perform(command)
      nil
    when 'close'
      IncidentCommands::Close.perform(command)
      nil
    when 'help'
      { text: "open: open a new incident \n update: update an ongoing incident \n close: close the incident" }
    else
      { text: 'This is not a valid command.' }
    end
  end
end
