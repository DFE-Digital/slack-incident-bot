# frozen_string_literal: true

module DryTypes
  # Call +Dry.Types()+ to add all registered types to +DryTypes+ which is
  # a container in this case. Check documentation for more information
  # https://dry-rb.org/gems/dry-types/1.2/getting-started/
  include Dry.Types()
end

module Grape
  module Validations
    module Types
      # A base class for classes which must identify a coercer to be used.
      # If the +strict+ argument is true, it won't coerce the given value
      # but check its type. More information there
      # https://dry-rb.org/gems/dry-types/1.2/built-in-types/
      class DryTypeCoercer
        class << self
          # Returns a collection coercer which corresponds to a given type.
          # Example:
          #
          #    collection_coercer_for(Array)
          #    #=> Grape::Validations::Types::ArrayCoercer
          def collection_coercer_for(type)
            case type
            when Array
              ArrayCoercer
            when Set
              SetCoercer
            else
              raise ArgumentError, "Unknown type: #{type}"
            end
          end

          # Returns an instance of a coercer for a given type
          def coercer_instance_for(type, strict = false)
            klass = type.instance_of?(Class) ? PrimitiveCoercer : collection_coercer_for(type)
            klass.new(type, strict)
          end
        end

        def initialize(type, strict = false)
          @type = type
          @strict = strict
          @scope = strict ? DryTypes::Strict : DryTypes::Params
        end

        # Coerces the given value to a type which was specified during
        # initialization as a type argument.
        #
        # @param val [Object]
        def call(val)
          return if val.nil?

          @coercer[val]
        rescue Dry::Types::CoercionError => _e
          InvalidValue.new
        end

        protected

        attr_reader :scope, :type, :strict
      end
    end
  end
end
