require 'rails_helper'

describe 'actions/slack_incident_listener' do
  include Rack::Test::Methods
  let(:client) { Slack::Web::Client.new }

  def app
    SlackRubyBotServer::Api::Middleware.instance
  end

  it 'checks signature' do
    post '/api/slack/action'
    expect(last_response.status).to eq 403
    response = JSON.parse(last_response.body)
    expect(response).to eq('error' => 'Invalid Signature')
  end

  context 'without signature checks' do
    before do
      allow_any_instance_of(Slack::Events::Request).to receive(:verify!)
    end

    context 'with a command' do
      let(:payload) do
        {
          'type' => 'view_submission',
          'view' => { 'app_id' => 'test' },
        }
      end

      it 'logs the action' do
        instance_double(Logger)
        expect_any_instance_of(Logger).to receive(:info).with('Received view_submission.')
        post '/api/slack/action', payload: payload.to_json
        expect(last_response.status).to eq 204
      end
    end
  end
end
