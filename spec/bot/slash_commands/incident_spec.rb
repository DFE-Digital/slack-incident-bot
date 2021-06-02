require 'rails_helper'

describe 'slash_commands/incident' do
  include Rack::Test::Methods

  def app
    SlackRubyBotServer::Api::Middleware.instance
  end

  before do
    allow_any_instance_of(Slack::Events::Request).to receive(:verify!)
  end

  let(:token) { 'xoxb-1234567891011-4444444444444-AbcDE6fgHijkLmNOpqrS4u1V'}
  let(:client) { Slack::Web::Client.new(token: token) }
  let(:trigger_id) { '12345.98765.abcd2358fdea' }
  let(:command) do
      {
        command: '/incident',
        text: '`',
        channel_id: 'channel',
        channel_name: 'channel_name',
        user_id: 'user_id',
        team_id: 'team_id',
        token: 'deprecated',
        trigger_id: trigger_id,
      }
  end
  let(:view){ '{"type":"modal","callback_id":"modal-identifier","title":{"type":"plain_text","text":"Raise an incident"},"submit":{"type":"plain_text","text":"Open"},"close":{"type":"plain_text","text":"Cancel","emoji":true},"blocks":[]}'}


    context 'with a hash for view' do
        it 'automatically converts view into JSON' do
            expect(client).to receive(:post).with('views.open', trigger_id: trigger_id, view: view)
            client.views_open(trigger_id: trigger_id, view: {
                type: 'modal',
                callback_id: 'modal-identifier',
                title: {
                    type: 'plain_text',
                    text: 'Raise an incident'
                },
                submit: {
                    type: 'plain_text',
                    text: 'Open'
                },
                close: {
                    type: 'plain_text',
                    text: 'Cancel',
                    emoji: true
                },
                blocks: []
            })
        end
    end


    context 'with an incident command' do
      it 'returns an incident modal' do
        expect_any_instance_of(Logger).to receive(:info).with('Someone raised an incident in channel channel.')
        post '/api/slack/command', command
        expect(last_response.status).to eq 204
        expect(JSON.parse(last_response.body)).to eq('text' => nil)
      end
    end
end