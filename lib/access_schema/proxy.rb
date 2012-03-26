module AccessSchema
  class Proxy

    def initialize(schema, options = {})
      @schema = schema
      @options = options
    end

    def roles
      @schema.roles
    end

    def plans
      @schema.plans
    end

    def allow?(*args)
      @schema.allow?(*normalize_args(args))
    end

    def require!(*args)
      @schema.require!(*normalize_args(args))
    end

    def with_options(options)
      Proxy.new(self, options)
    end

    private

    def normalize_args(args)
      resource = args[0]
      privilege = args[1]

      roles, options = case args[2]
      when Hash, nil
        [@options[:role] || @options[:plan], args[2] || {}]
      else
        [args[2], args[3] || {}]
      end

      options_to_pass = @options.dup
      options_to_pass.delete :plan
      options_to_pass.delete :role

      [resource, privilege, roles, options_to_pass.merge(options)]
    end

  end
end
