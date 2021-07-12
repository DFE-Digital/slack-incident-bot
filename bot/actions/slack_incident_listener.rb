SlackRubyBotServer::Events.configure do |config|
  config.on :action, 'view_submission' do |action|
    action.logger.info "Received #{action[:payload][:type]}."

    if action[:payload][:view][:app_id] == ENV['SLACK_APP_ID']
      t1 = Time.now
      SlackIncidentActions.new.open_incident(action)
      t2 = Time.now
      puts t2 - t1
    end
    nil
  end
end
