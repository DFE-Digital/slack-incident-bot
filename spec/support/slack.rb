require 'rspec/mocks'

class SlackMock
  extend RSpec::Mocks::ExampleMethods

  def self.realtime_client
    client = Slack::RealTime::Client.new

    allow(client).to receive(:start!)
    allow(client).to receive(:stop!)

    client
  end

  def self.web_client
    client = double(:client).as_null_object

    allow(Slack::Web::Client).to receive(:new).and_return(client)
    allow(client).to receive(:views_open)

    client
  end
end