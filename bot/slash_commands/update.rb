SlackRubyBotServer::Events.configure do |config|
  config.on :command, '/update' do |command|
    p command
    channel_name = command[:channel_name]
    channel_id = command[:channel_id]
    command.logger.info "Updating the incident in #{channel_name}"

    slack_client = Slack::Web::Client.new(token: ENV['SLACK_TOKEN'])

    begin
      if channel_name.include? 'incident'
        client = slack_client.views_open(trigger_id: command[:trigger_id], view: update_payload)
        Rails.cache.write(client['view']['id'], channel_id)
        { text: 'You’ve updated the incident.' }
      else
        { text: 'This is not an incident channel.' }
      end
    rescue Slack::Web::Api::Errors::NotInChannel
      { text: 'This is not an incident channel.' }
    rescue Slack::Web::Api::Errors::CantInvite
      { text: 'Cant invite this user' }
    rescue Slack::Web::Api::Errors::NoUser
      { text: 'No user' }
    end
  end
end

def update_payload
  JSON.parse(
    File.read(Rails.root.join('lib/view_payloads/update.json')),
  )
end
