require 'rails_helper'

RSpec.describe 'slash_commands/incident' do
  context 'with a command' do
    let(:command) do
      {
        command: '/incident',
        text: '',
        channel_id: 'test',
        channel_name: 'test_channel',
        user_id: 'user_id',
        team_id: 'team_id',
        token: 'deprecated',
        trigger_id: '12345.98765.abcd2358fdea',
      }
    end

    it 'logs a message about the incident' do
      expect(Logger).to receive(:info).with("Someone raised an incident in channel #{command[:channel_name]}.")
    end
  end
end
