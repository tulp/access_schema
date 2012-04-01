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

      case args[0]
      when String, Symbol
        resource = args[0].to_s
      else
        resource = args[0].class.name.to_s
        options.merge!(:subject => args[0])
      end

      roles = calculate_roles(roles, options)

      if (self.roles & roles).empty?
        raise InvalidRolesError.new(:roles => roles)
      end

      roles = sort_roles(roles)

      [resource, privilege, roles, options]
    end

    def calculate_roles(roles, check_options)

      roles = if roles.respond_to?(:call)
                roles.call(check_options.dup)
              elsif !roles.respond_to?(:map)
                [ roles ]
              else
                roles
              end

      unless roles.respond_to?(:map)
        raise InvalidRolesError.new(:result => roles)
      end

      roles.map(&:to_s)

    end

    def sort_roles(roles)
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

    def logger
      AccessSchema.config.logger
    end
  end
end
