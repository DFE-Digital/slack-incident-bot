require 'rails_helper'

describe 'slash_commands/close' do
  include Rack::Test::Methods

  def app
    SlackRubyBotServer::Api::Middleware.instance
  end

  context 'without signature checks' do
    before do
      allow_any_instance_of(Slack::Events::Request).to receive(:verify!)
    end

    context 'with a valid incident channel' do
      let!(:team) { Fabricate(:team) }
      let!(:web_client) { SlackMock.web_client }

      let(:command) do
        {
          command: '/closeincident',
          text: '`',
          channel_id: 'channel',
          channel_name: 'incident_channel_name',
          user_id: 'user_id',
          team_id: 'team_id',
          token: 'deprecated'
        }
      end

      it 'returns incident closed confirmation' do
        expect_any_instance_of(Logger).to receive(:info).with('Closing the incident in incident_channel_name.')
        post '/api/slack/command', command
        expect(last_response.status).to eq 201
        expect(JSON.parse(last_response.body)).to eq('text' => 'You’ve closed the incident.')
      end
    end

    context 'with an invalid incident channel' do
      let!(:team) { Fabricate(:team) }
      let!(:web_client) { SlackMock.web_client }

      let(:command) do
        {
          command: '/closeincident',
          text: '`',
          channel_id: 'channel',
          channel_name: 'channel_name',
          user_id: 'user_id',
          team_id: 'team_id',
          token: 'deprecated'
        }
      end

      it 'returns incident closed confirmation' do
        expect_any_instance_of(Logger).to receive(:info).with('Closing the incident in channel_name.')
        post '/api/slack/command', command
        expect(last_response.status).to eq 201
        expect(JSON.parse(last_response.body)).to eq('text' => 'This is not an incident channel.')
      end
    end
  end
end
