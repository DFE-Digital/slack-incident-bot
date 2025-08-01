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
      {
        text: <<~HELP_TEXT
      *open*: Initiate the incident bot by sending the message `/incident open` in your service Slack channel.

      *update*: Update an ongoing incident by sending the message `/incident update` in the incident Slack channel.

      *close*: Close the incident by sending the message `/incident close` in the incident Slack channel.
        HELP_TEXT
      }
    else
      { text: 'This is not a valid command.' }
    end
  end
end
