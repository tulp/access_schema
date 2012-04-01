module AccessSchema
  class Schema

    attr_reader :roles

    def initialize
      @roles = []
      @asserts = {}
      @resources = {}
    end

    def add_role(role)
      @roles << role
    end

    def add_assert(assert)
      @asserts[assert.name] = assert
    end

    def add_resource(resource)
      @resources[resource.name] = resource
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
      privilege =  args[1].to_s

      roles = args[2]
      roles = roles.respond_to?(:map) ? roles.map(&:to_s) : [roles && roles.to_s]

      raise NoRoleError.new if (self.roles & roles).empty?

      roles = normalize_roles_order(roles)

      case args[0]
      when String, Symbol
        resource = args[0].to_s
        [resource, privilege, roles, options]
      else
        resource = args[0].class.name.to_s
        [resource, privilege, roles, options.merge(:subject => args[0])]
      end

    end

    def normalize_roles_order(roles)
      @roles.select do |role|
        roles.include? role
      end
    end

    def check!(resource_name, privilege_name, roles, options)

      resouce_name = resource_name.to_s
      privilege_name = privilege_name.to_s

      resource = @resources[resource_name]

      if resource.nil?
        raise NoResourceError.new(:resource => resource_name)
      end

      privilege = resource.get_privilege(privilege_name)

      if privilege.nil?
        raise NoPrivilegeError.new(:resource => resource_name, :privilege => privilege_name)
      end

      failed_asserts = Hash.new{|h, k| h[k] = []}

      roles_checks = roles.map do |role|
        privilege.allow?([role]) do |expectation|
          @asserts[expectation.name].check?(expectation.options.merge(options)).tap do |result|
            failed_asserts[role] << expectation.name unless result
          end
        end
      end

      log_payload = {
        :resource => resource_name,
        :privilege => privilege_name,
        :roles => roles,
        :options => options
      }

      unless roles_checks.any?
        log_payload[:failed_asserts] = failed_asserts
        logger.info{ "check FAILED: #{log_payload.inspect}" }
        raise NotAllowedError.new(log_payload)
      else
        logger.debug{ "check PASSED: #{log_payload.inspect}" }
        true
      end

    end

    private

    def logger
      AccessSchema.config.logger
    end
  end
end
