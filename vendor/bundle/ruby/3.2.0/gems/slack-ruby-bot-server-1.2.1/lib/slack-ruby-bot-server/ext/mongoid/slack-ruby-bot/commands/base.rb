module SlackRubyBot
  module Commands
    class Base
      class << self
        alias _invoke invoke

        def invoke(client, data)
          _invoke client, data
        rescue Mongoid::Errors::Validations => e
          logger.info "#{name.demodulize.upcase}: #{client.owner}, error - #{e.document.class}, #{e.document.errors.to_hash}"
          client.say(channel: data.channel, text: e.document.errors.first[1])
          true
        rescue StandardError => e
          logger.info "#{name.demodulize.upcase}: #{client.owner}, #{e.class}: #{e}"
          logger.debug e.backtrace.join("\n")
          client.say(channel: data.channel, text: e.message)
          true
        end
      end
    end
  end
end
