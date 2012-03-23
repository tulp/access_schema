module AccessSchema
  class Schema

    attr_reader :roles
    alias :plans :roles

    def initialize
      @roles = []
      @asserts = {}
      @namespaces = {}
    end

    def add_role(role)
      @roles << role
    end

    def add_assert(assert)
      @asserts[assert.name] = assert
    end

    def add_namespace(namespace)
      @namespaces[namespace.name] = namespace
    end

    def allow?(*args)
      require!(*args)
    rescue NotAllowedError => e
      false
    else
      true
    end

    def require!(*args)
      check!(*normalize_args(args))
    end

    private

    def normalize_args(args)

      options = args.last.is_a?(Hash) ? args.pop : {}
      privilege =  args[1].to_sym

      roles = args[2]
      roles = roles.respond_to?(:map) ? roles.map(&:to_sym) : [roles && roles.to_sym]

      raise NoRoleError.new if (self.roles & roles).empty?


      case args[0]
      when String, Symbol
        namespace = args[0].to_sym
        [namespace, privilege, roles, options]
      else
        namespace = args[0].class.name.to_sym
        [namespace, privilege, roles, options.merge(:subject => args[0])]
      end

    end

    def check!(namespace_name, element_name, roles, options)

      existent_element = false
      failed_asserts = []

      allowed = for_element(namespace_name, element_name) do |element|
        existent_element = true
        element.allow?(roles) do |expectation|
          check_assert(expectation, options).tap do |result|
            failed_asserts << expectation unless result
          end
        end
      end

      raise NoPrivilegeError.new(:privilege => element_name.to_sym) unless existent_element

      log_payload = {
        :resource => namespace_name,
        :privilege => element_name,
        :roles => roles,
        :options => options
      }

      unless allowed
        log_payload[:failed_asserts] = failed_asserts.map(&:name)
        logger.info{ "check FAILED: #{log_payload.inspect}" }
        raise NotAllowedError.new(log_payload)
      else
        logger.debug{ "check PASSED: #{log_payload.inspect}" }
        true
      end

    end

    def check_assert(expectation, options)
      @asserts[expectation.name].check?(expectation.options.merge(options))
    end

    def for_element(namespace, element)
      ns = namespace.to_sym
      en = element.to_sym

      elements_for(ns).any? do |element|
        if element.name == en
          yield(element)
        end
      end

    end

    def elements_for(namespace)
      if @namespaces.has_key?(namespace)
        @namespaces[namespace].elements
      else
        raise NoResourceError.new(:resource => namespace)
      end
    end

    private

    def logger
      AccessSchema.config.logger
    end
  end
end
