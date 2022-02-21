require 'rails_helper'

describe 'slash_command/update' do
  include Rack::Test::Methods

  def app
    SlackRubyBotServer::Api::Middleware.instance
  end

  before do
    allow_any_instance_of(Slack::Events::Request).to receive(:verify!)
  end

  context 'with a valid update command' do
    let!(:web_client) { SlackMock.web_client }

    let(:command) do
      {
        command: '/update',
        text: '',
        channel_id: 'channel',
        channel_name: 'incident_channel_name',
        user_id: 'user_id',
        team_id: 'team_id',
        token: 'deprecated',
      }
    end

    it 'returns incident updated confirmation' do
      post '/api/slack/command', command
      expect(last_response.status).to eq 201
      expect(JSON.parse(last_response.body)).to eq('text' => 'You’ve updated the incident.')
    end
  end

  context 'with an invalid update command' do
    let!(:web_client) { SlackMock.web_client }

    let!(:command) do
      {
        command: '/update',
        text: '',
        channel_id: 'channel',
        channel_name: 'channel_name',
        user_id: 'user_id',
        team_id: 'team_id',
        token: 'deprecated',
      }
    end

    it 'returns the error message' do
      post '/api/slack/command', command
      expect(last_response.status).to eq 201
      expect(JSON.parse(last_response.body)).to eq('text' => 'This is not an incident channel.')
    end
  end
end
