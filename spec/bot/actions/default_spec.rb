require 'rails_helper'

describe 'actions/default' do
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

  context 'chat_postMessage' do
    it 'automatically converts attachments and blocks into JSON' do
      expect(client).to receive(:post).with(
        'chat.postMessage',
        channel: 'channel',
        text: 'text',
        attachments: '[]',
        blocks: '[]'
      )
      client.chat_postMessage(channel: 'channel', text: 'text', attachments: [], blocks: [])
    end

    it 'requires text, attachments or blocks' do
      expect { client.chat_postMessage(channel: 'channel') }.to(
        raise_error(ArgumentError, /Required arguments :text, :attachments or :blocks missing/)
      )
    end

    it 'only text' do
      expect(client).to receive(:post).with('chat.postMessage', hash_including(text: 'text'))
      expect { client.chat_postMessage(channel: 'channel', text: 'text') }.not_to raise_error
    end
  end

  context 'without signature checks' do
    before do
      allow_any_instance_of(Slack::Events::Request).to receive(:verify!)
    end

    context 'with a command' do
      let(:logger) { double(Logger) }
      let(:payload) do
        {
          'type' => 'view_submission',
          'view' => { 'app_id' => 'test' }
        }
      end

      it 'logs the action' do
        Logger.stub(:new).and_return(logger)
        allow(logger).to receive(:info)
        post '/api/slack/action', payload: payload.to_json
        expect(logger).to have_received(:info).with('Received view_submission.')
        expect(last_response.status).to eq 204
      end
    end
  end
end
