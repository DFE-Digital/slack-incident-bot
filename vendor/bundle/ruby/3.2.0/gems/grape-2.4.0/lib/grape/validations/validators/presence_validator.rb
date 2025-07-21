# frozen_string_literal: true

module Grape
  module Validations
    module Validators
      class PresenceValidator < Base
        def validate_param!(attr_name, params)
          return if params.try(:key?, attr_name)

          raise Grape::Exceptions::Validation.new(params: [@scope.full_name(attr_name)], message: message(:presence))
        end
      end
    end
  end
end
