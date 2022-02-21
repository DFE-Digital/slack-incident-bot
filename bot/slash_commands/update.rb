SlackRubyBotServer::Events.configure do |config|
  config.on :command, '/update' do |command|
    channel_name = command[:channel_name]
    channel_id = command[:channel_id]

    begin
      if channel_name.include? 'incident'
        SlackMethods.open_the_modal(command[:trigger_id], update_payload)
        Rails.cache.write('channel_id', channel_id)
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
