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

      privilege =  args[1].to_s
      options = args.last.is_a?(Hash) ? args.pop : {}

      unless subject_by_name?(args[0])
        options.merge! :subject => args[0]
      end

      roles = calculate_roles(args[2], options)

      if (self.roles & roles).empty?
        raise InvalidRolesError.new(:roles => roles)
      end

      [
        resource_name(args[0]),
        privilege,
        sort_roles(roles),
        options
      ]
    end

    def resource_name(obj)
      if subject_by_name?(obj)
        obj.to_s
      else
        klass = obj.class
        if klass.respond_to?(:model_name)
          klass.model_name
        else
          klass.name
        end
      end
    end

    def subject_by_name?(obj)
      case obj
      when String, Symbol
        true
      else
        false
      end
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

          assert = @asserts[expectation.name]
          check_options = expectation.options.merge(options)

          assert.check?(check_options).tap do |result|
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
