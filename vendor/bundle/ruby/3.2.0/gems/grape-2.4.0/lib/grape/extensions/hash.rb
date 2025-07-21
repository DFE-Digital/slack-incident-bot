# frozen_string_literal: true

module Grape
  module Extensions
    module Hash
      module ParamBuilder
        extend ::ActiveSupport::Concern

        included do
          Grape.deprecator.warn 'This concern has been deprecated. Use `build_with` with one of the following short_name (:hash, :hash_with_indifferent_access, :hashie_mash) instead.'
          namespace_inheritable(:build_params_with, :hash)
        end

        def build_params
          rack_params.deep_dup.tap do |params|
            params.deep_symbolize_keys!

            if env.key?(Grape::Env::GRAPE_ROUTING_ARGS)
              grape_routing_args.deep_symbolize_keys!
              params.deep_merge!(grape_routing_args)
            end
          end
        end
      end
    end
  end
end
