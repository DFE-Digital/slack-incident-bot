require 'rails_helper'

describe 'slash_commands/incident' do
  include Rack::Test::Methods

  def app
    SlackRubyBotServer::Api::Middleware.instance
  end

  context 'without signature checks' do
    before do
      allow_any_instance_of(Slack::Events::Request).to receive(:verify!)
    end

    context 'with a command' do
      let!(:web_client) { SlackMock.web_client }
      let!(:team) { Fabricate(:team) }
      let(:trigger_id) { '12345.98765.abcd2358fdea' }
      let(:command) do
        {
          command: '/incident',
          text: '`',
          channel_id: 'test',
          channel_name: 'test_channel',
          user_id: 'user_id',
          team_id: 'team_id',
          token: 'deprecated',
          trigger_id: trigger_id,
        }
      end

      it 'successfully processes the request' do
        allow_any_instance_of(Logger).to receive(:info).with("Someone raised an incident in channel #{command[:channel_name]}.")
        post '/api/slack/command', command
        expect(last_response.status).to eq 204
      end
    end
  end
end