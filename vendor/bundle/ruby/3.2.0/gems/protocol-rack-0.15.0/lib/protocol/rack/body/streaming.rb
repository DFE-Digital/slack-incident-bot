# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022-2024, by Samuel Williams.

require "protocol/http/body/streamable"

module Protocol
	module Rack
		module Body
			Streaming = ::Protocol::HTTP::Body::Streamable::ResponseBody
		end
	end
end
