# frozen_string_literal: true

module Grape
  class API
    # The API Instance class, is the engine behind Grape::API. Each class that inherits
    # from this will represent a different API instance
    class Instance
      extend Grape::Middleware::Auth::DSL
      include Grape::DSL::API

      class << self
        attr_reader :instance, :base
        attr_accessor :configuration

        def given(conditional_option, &block)
          evaluate_as_instance_with_configuration(block, lazy: true) if conditional_option && block
        end

        def mounted(&block)
          evaluate_as_instance_with_configuration(block, lazy: true)
        end

        def base=(grape_api)
          @base = grape_api
          grape_api.instances << self
        end

        def to_s
          base&.to_s || super
        end

        def base_instance?
          self == base.base_instance
        end

        # A class-level lock to ensure the API is not compiled by multiple
        # threads simultaneously within the same process.
        LOCK = Mutex.new

        # Clears all defined routes, endpoints, etc., on this API.
        def reset!
          reset_endpoints!
          reset_routes!
          reset_validations!
        end

        # Parses the API's definition and compiles it into an instance of
        # Grape::API.
        def compile
          @instance ||= new # rubocop:disable Naming/MemoizedInstanceVariableName
        end

        # Wipe the compiled API so we can recompile after changes were made.
        def change!
          @instance = nil
        end

        # This is the interface point between Rack and Grape; it accepts a request
        # from Rack and ultimately returns an array of three values: the status,
        # the headers, and the body. See [the rack specification]
        # (http://www.rubydoc.info/github/rack/rack/master/file/SPEC) for more.
        def call(env)
          compile!
          call!(env)
        end

        # A non-synchronized version of ::call.
        def call!(env)
          instance.call(env)
        end

        # (see #cascade?)
        def cascade(value = nil)
          if value.nil?
            inheritable_setting.namespace_inheritable.key?(:cascade) ? !namespace_inheritable(:cascade).nil? : true
          else
            namespace_inheritable(:cascade, value)
          end
        end

        def compile!
          return if instance

          LOCK.synchronize { compile unless instance }
        end

        # see Grape::Router#recognize_path
        def recognize_path(path)
          compile!
          instance.router.recognize_path(path)
        end

        protected

        def prepare_routes
          endpoints.map(&:routes).flatten
        end

        # Execute first the provided block, then each of the
        # block passed in. Allows for simple 'before' setups
        # of settings stack pushes.
        def nest(*blocks, &block)
          blocks.compact!
          if blocks.any?
            evaluate_as_instance_with_configuration(block) if block
            blocks.each { |b| evaluate_as_instance_with_configuration(b) }
            reset_validations!
          else
            instance_eval(&block)
          end
        end

        def evaluate_as_instance_with_configuration(block, lazy: false)
          lazy_block = Grape::Util::Lazy::Block.new do |configuration|
            value_for_configuration = configuration
            self.configuration = value_for_configuration.evaluate if value_for_configuration.try(:lazy?)
            response = instance_eval(&block)
            self.configuration = value_for_configuration
            response
          end
          if base && base_instance? && lazy
            lazy_block
          else
            lazy_block.evaluate_from(configuration)
          end
        end

        def inherited(subclass)
          super
          subclass.reset!
          subclass.logger = logger.clone
        end

        def inherit_settings(other_settings)
          top_level_setting.inherit_from other_settings.point_in_time_copy

          # Propagate any inherited params down to our endpoints, and reset any
          # compiled routes.
          endpoints.each do |e|
            e.inherit_settings(top_level_setting.namespace_stackable)
            e.reset_routes!
          end

          reset_routes!
        end
      end

      attr_reader :router

      # Builds the routes from the defined endpoints, effectively compiling
      # this API into a usable form.
      def initialize
        @router = Router.new
        add_head_not_allowed_methods_and_options_methods
        self.class.endpoints.each do |endpoint|
          endpoint.mount_in(@router)
        end

        @router.compile!
        @router.freeze
      end

      # Handle a request. See Rack documentation for what `env` is.
      def call(env)
        status, headers, response = @router.call(env)
        unless cascade?
          headers = Grape::Util::Header.new.merge(headers)
          headers.delete('X-Cascade')
        end

        [status, headers, response]
      end

      # Some requests may return a HTTP 404 error if grape cannot find a matching
      # route. In this case, Grape::Router adds a X-Cascade header to the response
      # and sets it to 'pass', indicating to grape's parents they should keep
      # looking for a matching route on other resources.
      #
      # In some applications (e.g. mounting grape on rails), one might need to trap
      # errors from reaching upstream. This is effectivelly done by unsetting
      # X-Cascade. Default :cascade is true.
      def cascade?
        return self.class.namespace_inheritable(:cascade) if self.class.inheritable_setting.namespace_inheritable.key?(:cascade)
        return self.class.namespace_inheritable(:version_options)[:cascade] if self.class.namespace_inheritable(:version_options)&.key?(:cascade)

        true
      end

      reset!

      private

      # For every resource add a 'OPTIONS' route that returns an HTTP 204 response
      # with a list of HTTP methods that can be called. Also add a route that
      # will return an HTTP 405 response for any HTTP method that the resource
      # cannot handle.
      def add_head_not_allowed_methods_and_options_methods
        # The paths we collected are prepared (cf. Path#prepare), so they
        # contain already versioning information when using path versioning.
        all_routes = self.class.endpoints.map(&:routes).flatten

        # Disable versioning so adding a route won't prepend versioning
        # informations again.
        without_root_prefix_and_versioning { collect_route_config_per_pattern(all_routes) }
      end

      def collect_route_config_per_pattern(all_routes)
        routes_by_regexp = all_routes.group_by(&:pattern_regexp)

        # Build the configuration based on the first endpoint and the collection of methods supported.
        routes_by_regexp.each_value do |routes|
          last_route = routes.last # Most of the configuration is taken from the last endpoint
          next if routes.any? { |route| route.request_method == '*' }

          allowed_methods = routes.map(&:request_method)
          allowed_methods |= [Rack::HEAD] if !self.class.namespace_inheritable(:do_not_route_head) && allowed_methods.include?(Rack::GET)

          allow_header = self.class.namespace_inheritable(:do_not_route_options) ? allowed_methods : [Rack::OPTIONS] | allowed_methods
          last_route.app.options[:options_route_enabled] = true unless self.class.namespace_inheritable(:do_not_route_options) || allowed_methods.include?(Rack::OPTIONS)

          @router.associate_routes(last_route.pattern, {
                                     endpoint: last_route.app,
                                     allow_header: allow_header
                                   })
        end
      end

      # Allows definition of endpoints that ignore the versioning configuration
      # used by the rest of your API.
      def without_root_prefix_and_versioning
        old_version = self.class.namespace_inheritable(:version)
        old_version_options = self.class.namespace_inheritable(:version_options)
        old_root_prefix = self.class.namespace_inheritable(:root_prefix)

        self.class.namespace_inheritable_to_nil(:version)
        self.class.namespace_inheritable_to_nil(:version_options)
        self.class.namespace_inheritable_to_nil(:root_prefix)

        yield

        self.class.namespace_inheritable(:version, old_version)
        self.class.namespace_inheritable(:version_options, old_version_options)
        self.class.namespace_inheritable(:root_prefix, old_root_prefix)
      end
    end
  end
end
