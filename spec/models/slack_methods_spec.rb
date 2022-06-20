require 'rails_helper'

describe SlackMethods do
  describe '.summary_for' do
    let(:incident) { instance_double('SlackIncidentModal') }

    before do
      allow(incident).to receive(:description).and_return('test description')
      allow(incident).to receive(:priority).and_return('test priority')
    end

    context 'when all leads are provided' do
      it 'includes the full summary' do

        allow(incident).to receive(:comms_lead).and_return('test_comms')
        allow(incident).to receive(:tech_lead).and_return('test_tech')
        allow(incident).to receive(:support_lead).and_return('test_support')

        expect(described_class.summary_for(incident)).to eq "Description: Test description\n Priority: test priority\nComms lead: <@test_comms>\nTech lead: <@test_tech>\nSupport lead: <@test_support>"
      end
    end

    context 'when one lead is provided' do
      it 'includes description, priority and the provided lead' do
        allow(incident).to receive(:comms_lead).and_return(nil)
        allow(incident).to receive(:tech_lead).and_return('test_tech')
        allow(incident).to receive(:support_lead).and_return(nil)

        expect(described_class.summary_for(incident)).to eq "Description: Test description\n Priority: test priority\nTech lead: <@test_tech>\n"
      end
    end

    context 'when no leads are provied' do
      it 'only includes the description and priority' do
        allow(incident).to receive(:comms_lead).and_return(nil)
        allow(incident).to receive(:tech_lead).and_return(nil)
        allow(incident).to receive(:support_lead).and_return(nil)

        expect(described_class.summary_for(incident)).to eq "Description: Test description\n Priority: test priority\n"
      end
    end
  end
end
