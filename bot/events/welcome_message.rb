SlackRubyBotServer::Events.configure do |config|
  config.on :event, ['event_callback', 'member_joined_channel'] do |event|

    channel_name = SlackMethods.channel_name(event[:event][:channel])

    if channel_name.include? 'incident'
      incident_title = channel_name.split('_').drop(3).join('-')
      name = SlackMethods.users_name(event[:event][:user])
      user_id = SlackMethods.user_id(event[:event][:user])

      SlackMethods.post_a_message_to_user(channel_name, user_id, "Welcome #{name} to the incident channel. Please review the docs and join the <http://g.co/meet/#{incident_title}| discussion>.")
    end

    { ok: true }
  end
end
