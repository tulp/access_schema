module AccessSchema
  class Schema

    attr_reader :roles

    def initialize
      @roles = []
      @asserts = {}
      @resources = {}
    end

    def build_assert(name, vars, &block)
      assert = Assert.new(self, name, vars, &block)
      @asserts[assert.name] = assert
    end

    def build_resource(name)
      resource = Resource.new(self, name)
      @resources[resource.name] = resource
    end

    def add_role(role)
      @roles << role
    end

    def assert_by_name(name)
      @asserts[name.to_s]
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

    def to_s
      "#{self.class.name}:#{object_id} roles: #{roles} asserts: #{@asserts.keys} resources: #{@resources.keys}"
    end

    private

    def normalize_args(args)

      privilege =  args[1].to_s
      options = args.last.is_a?(Hash) ? args.pop : {}

      if !subject_by_name?(args[0]) && options[:subject].nil?
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

      resource = resource_by_name!(resource_name)
      privilege = privilege_by_name!(resource, privilege_name)

      results = roles.inject({}) do |h, role|
        h[role] = privilege.check([role], options)
        h
      end

      log_payload = {
        :resource => resource_name,
        :privilege => privilege_name,
        :roles => roles,
        :options => options,
        :results => results
      }

      pass = roles.any? do |role|
        rr = results[role]
        rr && rr.positive?
      end

      if pass
        logger.debug{ "check PASSED: #{log_payload.inspect}" }
        true
      else
        logger.info{ "check FAILED: #{log_payload.inspect}" }
        raise NotAllowedError.new(log_payload)
      end

    end

    def resource_by_name!(name)
      @resources[name] or raise NoResourceError.new(:resource => name)
    end

    def privilege_by_name!(resource, name)
      resource.get_privilege(name) or raise NoPrivilegeError.new(:resource => resource_name, :privilege => name)
    end

    def logger
      AccessSchema.config.logger
    end

  end
end
