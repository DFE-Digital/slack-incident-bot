require 'rails_helper'

describe 'actions/slack_incident_actions' do
    let(:client) { Slack::Web::Client.new }

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
end
