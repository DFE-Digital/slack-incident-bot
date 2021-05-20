class Api < Grape::API
  prefix 'api'
  format :json
  mount SlackRubyBotServer::Api::Endpoints::RootEndpoint
end
